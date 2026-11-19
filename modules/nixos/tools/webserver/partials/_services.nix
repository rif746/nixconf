{ user, cfg }:
{ lib, pkgs, ... }:
{
  config = lib.mkIf cfg.enable {
    services = {
      mailpit.instances.default = { };

      redis = {
        vmOverCommit = false;
        servers.default = {
          enable = true;
          port = 6379;
        };
      };

      mysql = {
        enable = true;
        package = pkgs.mariadb;
      };
    };

    users.users.${user.name}.extraGroups = [
      "mysql"
      "wwwrun"
    ];
  };
}
