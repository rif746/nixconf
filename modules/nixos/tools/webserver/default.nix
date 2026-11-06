{ ... }: {
  flake.nixosModules.devkit-webserver =
    {
      user,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.nixos.tools.webserver;

      mkPhpPool = version: {
        user = user.name;
        group = "users";
        settings = {
          "pm" = "dynamic";
          "pm.max_children" = 5;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 1;
          "pm.max_spare_servers" = 3;

          "listen.owner" = user.name;
          "listen.group" = "users";
          "listen.mode" = "0660";
        };
      };

      certDir = "/var/lib/ssl";

      devkitCerts =
        pkgs.runCommand "devkit-certs"
          {
            nativeBuildInputs = [ pkgs.mkcert ];
          }
          ''
            mkdir -p $out/ca $out/certs
            export CAROOT=$out/ca

            mkcert -install

            mkcert -cert-file $out/certs/localhost.crt -key-file $out/certs/localhost.key "*.test" "localhost" "127.0.0.1" "::1"
            mkcert -cert-file $out/certs/mailpit.crt -key-file $out/certs/mailpit.key "mailpit.test" "*.mailpit.test"
          '';
    in
    {
      options.nixos.tools.webserver = {
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
          pkgs.php
        ];

        security.pki.certificateFiles = [
          "${devkitCerts}/ca/rootCA.pem"
        ];

        systemd.services.phpfpm-php85.serviceConfig.ProtectHome = lib.mkForce false;
        systemd.services.phpfpm-php83.serviceConfig.ProtectHome = lib.mkForce false;

        services = {
          phpfpm.pools = {
            php83 = (mkPhpPool "8.3") // {
              phpPackage = pkgs.php83.withExtensions (
                { enabled, all }:
                with all;
                enabled
                ++ [
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
                ]
              );
            };

            php85 = (mkPhpPool "8.5") // {
              phpPackage = pkgs.php85.withExtensions (
                { enabled, all }:
                with all;
                enabled
                ++ [
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
                ]
              );
            };
          };

          mailpit.instances.default = { };

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

            user = user.name;
            group = "users";

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

              # 3. Izinkan Apache mengakses root directory /home/syarif secara eksplisit
              <Directory "/home/${user.name}">
                  Options Indexes FollowSymLinks ExecCGI
                  AllowOverride All
                  Require all granted
              </Directory>

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

                  ProxyPreserveHost Off

                  RewriteEngine On
                  RewriteCond %{HTTP:Upgrade} =websocket [NC]
                  RewriteRule /(.*)           ws://127.0.0.1:8025/$1 [P,L]

                  ProxyPass / http://127.0.0.1:8025/ retry=0 timeout=5
                  ProxyPassReverse / http://127.0.0.1:8025/

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

        users.users.${user.name}.extraGroups = [
          "mysql"
          "wwwrun"
        ];

        security.sudo.extraRules = [
          {
            users = [ user.name ];
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

        networking.nameservers = [
          "127.0.0.1"
          "::1"
        ];
        networking.firewall.allowedTCPPorts = [
          80
          443
          1025
          8025
        ];

        systemd.tmpfiles.rules = [
          "d /run/httpd 0755 ${user.name} users -"

          "d ${certDir} 0775 ${user.name} users -"
          "d ${certDir}/ca 0775 ${user.name} users -"
          "L+ ${certDir}/ca/rootCA.pem - - - - ${devkitCerts}/ca/rootCA.pem"
          "L+ ${certDir}/ca/rootCA-key.pem - - - - ${devkitCerts}/ca/rootCA-key.pem"

          "d /var/lib/apache-vhosts 0775 ${user.name} users -"
          "d /var/www 0775 ${user.name} users -"
          "d /var/www/default 0755 ${user.name} users -"

          "L+ /var/www/default/index.html - - - - ${pkgs.writeText "404.html" (builtins.readFile ./templates/404.html)}"
          "L+ /var/www/default/403.html - - - - ${pkgs.writeText "403.html" (builtins.readFile ./templates/403.html)}"
          "L+ /var/www/default/500.html - - - - ${pkgs.writeText "500.html" (builtins.readFile ./templates/500.html)}"
          "L+ /var/www/default/503.html - - - - ${pkgs.writeText "503.html" (builtins.readFile ./templates/503.html)}"
        ];

      };

    };
}
