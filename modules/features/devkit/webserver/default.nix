{ ... }: {
  flake.nixosModules.devkit-webserver = { config, lib, pkgs, ... }: let
    cfg = config.modules.devkit.webserver;
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
      services = {
        httpd = {
          enable = true;
          adminAddr = "admin@localhost";
          enablePHP = true;

          virtualHosts = {
            "syarif.test" = {
              documentRoot = "/var/www/syarif.test";
              locations."/".index = "index.php index.html";
            };
          };
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

      # Hak akses user utama ke grup webserver & database
      users.users.${cfg.mainUser}.extraGroups = [ "mysql" "wwwrun" ];

      # Routing DNS lokal & Firewall
      networking.nameservers = [ "127.0.0.1" "::1" ];
      networking.firewall.allowedTCPPorts = [ 80 443 ];

      # Membuat direktori web root dan file test index.php secara otomatis
      systemd.tmpfiles.rules = [
        "d /var/www 0755 wwwrun wwwrun -"
        "d /var/www/syarif.test 0775 wwwrun wwwrun -"
        "f /var/www/syarif.test/index.php 0664 wwwrun wwwrun - <?php phpinfo();"
      ];
    };
  };
}
