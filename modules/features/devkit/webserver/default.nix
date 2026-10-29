   { ... }: {
  flake.nixosModules.devkit-webserver = { config, lib, pkgs, ... }: let
    cfg = config.modules.devkit.webserver;

    mkPhpPool = version: {
      user = user; # Runs as 'syarif' so you never get permission blocks
      group = "users";     # Matches your /mnt/data drive group profile
      settings = {
        "pm" = "dynamic";
        "pm.max_children" = 5;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;

        # Sockets must be writable by Apache (wwwrun)
        "listen.owner" = "wwwrun";
        "listen.group" = "wwwrun";
        "listen.mode" = "0660";
      };
    };

    certDir = "/var/lib/ssl";
    user = config.system.user.name;

    # Generate CA & SSL Certs di dalam Nix Store secara deterministik saat build
    devkitCerts = pkgs.runCommand "devkit-certs" {
      nativeBuildInputs = [ pkgs.mkcert ];
    } ''
      mkdir -p $out/ca $out/certs
      export CAROOT=$out/ca

      # Generate Root CA
      mkcert -install

      # Generate Wildcard Cert
      mkcert -cert-file $out/certs/localhost.crt -key-file $out/certs/localhost.key "*.test" "localhost" "127.0.0.1" "::1"
      mkcert -cert-file $out/certs/mailpit.crt -key-file $out/certs/mailpit.key "mailpit.test" "*.mailpit.test"
    '';
  in {
    options.modules.devkit.webserver = {
      enable = lib.mkEnableOption "Local Web Development Environment (Apache, MariaDB, Dnsmasq for *.test)";

      mailpitDomain = lib.mkOption {
        type = lib.types.str;
        default = "mailpit.test";
        description = "Domain name to access Mailpit web UI";
      };
    };

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "web-link" (builtins.readFile ./scripts/web-link.sh))
        (pkgs.writeShellScriptBin "web-unlink" (builtins.readFile ./scripts/web-unlink.sh))

        pkgs.mkcert
        pkgs.nssTools
        pkgs.php85
      ];

      systemd.services = {
        httpd = {
          serviceConfig = {
            ProtectHome = lib.mkForce false;
            ProtectSystem = lib.mkForce false;
            PrivateTmp = lib.mkForce false;

            ReadWritePaths = [
              "/var/lib/apache-vhosts"
              "/mnt/data/Project/Web"
              "/home/${user}"
              certDir
            ];
          };
        };
      };

      security.pki.certificateFiles = [
        "${devkitCerts}/ca/rootCA.pem"
      ];

      services = {
        phpfpm.pools = {
          # PHP 8.3 Legacy Stack (Socket will sit at /run/phpfpm/php83.sock)
          php83 = (mkPhpPool "8.3") // {
            phpPackage = pkgs.php83.withExtensions ({ enabled, all }: with all; enabled ++ [
              gd
              zip
              mbstring
              pdo_sqlite
              sqlite3
              pdo_mysql
              bcmath
              curl
              openssl
              tokenizer
              fileinfo
              redis
            ]);
          };

          # PHP 8.5 Stack (Socket will sit at /run/phpfpm/php85.sock)
          php85 = (mkPhpPool "8.5") // {
            phpPackage = pkgs.php85.withExtensions ({ enabled, all }: with all; enabled ++ [
              gd
              zip
              mbstring
              pdo_sqlite
              sqlite3
              pdo_mysql
              bcmath
              curl
              openssl
              tokenizer
              fileinfo
              redis
            ]);
          };
        };

        mailpit.instances.default = {};

        redis = {
          vmOverCommit = false;
          servers.default = {
            enable = true;
            port = 6379;
          };
        };

        httpd = {
          enable = true;
          adminAddr = "admin@localhost";
          enablePHP = true;

         extraModules = [
            "rewrite"
            "vhost_alias"
            "alias"
            "proxy"
            "proxy_fcgi"
            "proxy_http"
            "proxy_wstunnel"
            "remoteip"
            "headers"
            "ssl"
          ];

         extraConfig = ''
            Listen 443 https
            DefaultRuntimeDir "/run/httpd"
            SSLCertificateFile ${devkitCerts}/certs/localhost.crt
            SSLCertificateKeyFile ${devkitCerts}/certs/localhost.key

            Alias /403.html /var/www/default/403.html
            Alias /500.html /var/www/default/500.html
            Alias /503.html /var/www/default/503.html

            ErrorDocument 403 /403.html
            ErrorDocument 500 /500.html
            ErrorDocument 503 /503.html

            # Default Fallback VHost (HTTP - Port 80)
            <VirtualHost *:80>
                ServerName default.test
                ServerAlias *.test localhost 127.0.0.1
                DocumentRoot "/var/www/default"

                <Directory "/var/www/default">
                    AllowOverride None
                    Require all granted
                </Directory>
            </VirtualHost>

            # Default Fallback VHost (HTTPS - Port 443)
            <VirtualHost *:443>
                ServerName default.test

                SSLEngine on
                SSLCertificateFile ${devkitCerts}/certs/localhost.crt
                SSLCertificateKeyFile ${devkitCerts}/certs/localhost.key

                DocumentRoot "/var/www/default"

                <Directory "/var/www/default">
                    AllowOverride None
                    Require all granted
                </Directory>
            </VirtualHost>

            # Mailpit SSL Reverse Proxy
            <VirtualHost *:443>
                ServerName ${cfg.mailpitDomain}

               SSLEngine on
                SSLCertificateFile ${devkitCerts}/certs/mailpit.crt
                SSLCertificateKeyFile ${devkitCerts}/certs/mailpit.key

               # Matikan ProxyPreserveHost agar Mailpit tidak kebingungan menerima Host: mailpit.test
                ProxyPreserveHost Off

               # WebSocket Support untuk Real-time Updates (Mailpit UI)
                RewriteEngine On
                RewriteCond %{HTTP:Upgrade} =websocket [NC]
                RewriteRule /(.*)           ws://127.0.0.1:8025/$1 [P,L]

               # HTTP Proxy Mapping
                ProxyPass / http://127.0.0.1:8025/ retry=0 timeout=5
                ProxyPassReverse / http://127.0.0.1:8025/

               # Mencegah error SSL handshake/proxy pada lingkungan lokal
                SSLProxyEngine Off

               <Location />
                    Require all granted
               </Location>
             </VirtualHost>

            <Directory "/var/www">
                Options Indexes FollowSymLinks
                AllowOverride None
                Require all granted
            </Directory>

            <Directory "/var/www/default">
                Options Indexes FollowSymLinks
                AllowOverride None
                Require all granted
            </Directory>

           IncludeOptional /var/lib/apache-vhosts/*.conf
          '';
        };

       mysql = {
          enable = true;
          package = pkgs.mariadb;
        };

       dnsmasq = {
          enable = true;
          settings = {
            address = [
              "/.test/127.0.0.1"
              "/.test/::1"
            ];
            interface = "lo";
            bind-interfaces = true;
            no-dhcp-interface = "lo";
          };
        };
      };

      users.users.${user}.extraGroups = [ "mysql" "wwwrun" ];
      security.sudo.extraRules = [
        {
          users = [ user ];
          commands = [
            {
              command = "/run/current-system/sw/bin/systemctl reload httpd";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/chmod";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      networking.nameservers = [ "127.0.0.1" "::1" ];
      networking.firewall.allowedTCPPorts = [ 80 443 1025 8025 ];

      systemd.tmpfiles.rules = [
        "d /run/httpd 0755 wwwrun wwwrun -"

        # Direktori SSL nyata yang bisa ditulis oleh syarif & wwwrun
        "d ${certDir} 0775 ${user} wwwrun -"
        "d ${certDir}/ca 0775 ${user} wwwrun -"
        "L+ ${certDir}/ca/rootCA.pem - - - - ${devkitCerts}/ca/rootCA.pem"
        "L+ ${certDir}/ca/rootCA-key.pem - - - - ${devkitCerts}/ca/rootCA-key.pem"

        "d /var/lib/apache-vhosts 0775 wwwrun wwwrun -"
        "d /var/www 0775 wwwrun wwwrun -"
        "d /var/www/default 0755 wwwrun wwwrun -"

        # Deploy all fallback web layouts natively using symlinks
        "L+ /var/www/default/index.html - - - - ${pkgs.writeText "404.html" (builtins.readFile ./templates/404.html)}"
        "L+ /var/www/default/403.html - - - - ${pkgs.writeText "403.html" (builtins.readFile ./templates/403.html)}"
        "L+ /var/www/default/500.html - - - - ${pkgs.writeText "500.html" (builtins.readFile ./templates/500.html)}"
        "L+ /var/www/default/503.html - - - - ${pkgs.writeText "503.html" (builtins.readFile ./templates/503.html)}"
      ];

    };

  };

}
