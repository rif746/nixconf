  { ... }: {
  flake.nixosModules.devkit-webserver = { config, lib, pkgs, ... }: let
    cfg = config.modules.devkit.webserver;

    mkPhpPool = version: {
      user = cfg.mainUser; # Runs as 'syarif' so you never get permission blocks
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
  in {
    options.modules.devkit.webserver = {
      enable = lib.mkEnableOption "Local Web Development Environment (Apache, MariaDB, Dnsmasq for *.test)";

      mainUser = lib.mkOption {
        type = lib.types.str;
        default = "syarif";
        description = "Primary user to be granted wwwrun and mysql group permissions";
      };
    };

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "web-link" (builtins.readFile ./scripts/web-link.sh))

        pkgs.php83
        pkgs.php85
      ];

      systemd.services.httpd = {
        serviceConfig = {
          ProtectHome = lib.mkForce false;
          ProtectSystem = lib.mkForce false;
          PrivateTmp = lib.mkForce false;

          ReadWritePaths = [
            "/var/lib/apache-vhosts"
          ];
          ReadOnlyPaths = [
            "/mnt/data"
            "/var/www"
          ];
        };
      };

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
            "remoteip"
            "headers"
          ];

          extraConfig = ''
            Alias /403.html /var/www/default/403.html
            Alias /500.html /var/www/default/500.html
            Alias /503.html /var/www/default/503.html

            ErrorDocument 403 /403.html
            ErrorDocument 500 /500.html
            ErrorDocument 503 /503.html

            # ====================================================================
            # MIMIC CLOUDFLARE NETWORK HEADERS
            # ====================================================================
            SetEnvIf Request_URI "^" HTTP_CF_RAY=95afc0deb1234567-SUB
            SetEnvIf Request_URI "^" HTTP_CF_CONNECTING_IP=203.0.113.195
            SetEnvIf Request_URI "^" HTTP_X_FORWARDED_FOR=203.0.113.195
            SetEnvIf Request_URI "^" HTTP_CF_IPCOUNTRY=ID

            # Tell Apache to trust CF-Connecting-IP as the true visitor IP address
            RemoteIPHeader CF-Connecting-IP
            RemoteIPTrustedProxy 127.0.0.1 ::1

            # Inject fake Cloudflare proxy signatures into EVERY incoming local request
            RequestHeader set CF-Connecting-IP "203.0.113.195"
            RequestHeader set CF-IPCountry "ID"
            RequestHeader set CF-RAY "95afc0deb1234567-SUB"
            RequestHeader set CF-Visitor "{\"scheme\":\"http\"}"
            # ====================================================================


            <Directory "/home/${cfg.mainUser}">
                Options FollowSymLinks
                AllowOverride None
                Require all granted
            </Directory>

            <Directory "/home/${cfg.mainUser}/Projects">
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Require all granted
            </Directory>

            <VirtualHost *:80>
                ServerName localhost
                DocumentRoot "/var/www/default"

                <Directory "/var/www/default">
                    AllowOverride None
                    Require all granted
                </Directory>
            </VirtualHost>

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

      users.users.${cfg.mainUser}.extraGroups = [ "mysql" "wwwrun" ];
      security.sudo.extraRules = [
        {
          users = [ cfg.mainUser ];
          commands = [
            {
              command = "/run/current-system/sw/bin/systemctl reload httpd";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      networking.nameservers = [ "127.0.0.1" "::1" ];
      networking.firewall.allowedTCPPorts = [ 80 443 ];

      systemd.tmpfiles.rules = [
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
