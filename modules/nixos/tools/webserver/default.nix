{ ... }:
{
  flake.nixosModules.tools-webserver =
    {
      user,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.nixos.tools.webserver;
      certDir = "/var/lib/ssl";
    in
    {
      imports = [
        (import ./partials/_php.nix { inherit user cfg; })
        (import ./partials/_httpd.nix { inherit user cfg certDir; })
        (import ./partials/_services.nix { inherit user cfg; })
        (import ./partials/_dns-ssl.nix { inherit user cfg certDir; })
      ];

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
          (pkgs.writeShellScriptBin "web" (builtins.readFile ./scripts/web.sh))
          pkgs.nodejs
          pkgs.nss
          pkgs.openssl
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

        systemd.tmpfiles.rules = [
          "d /run/httpd 0755 ${user.name} users -"

          "d ${certDir} 0775 ${user.name} users -"
          "d ${certDir}/ca 0775 ${user.name} users -"

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
