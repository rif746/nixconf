{ user, cfg }:
{ lib, pkgs, ... }:
let
  mkPhpPool = phpPkg: {
    user = user.name;
    group = "users";
    phpPackage = phpPkg.withExtensions (
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
in
{
  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        php
        phpPackages.composer
      ];

      sessionVariables = {
        COMPOSER_HOME = "/home/${user.name}/.config/composer";
        PATH = [
          "/home/${user.name}/.config/composer/vendor/bin"
        ];
      };
    };

    systemd.services = {
      phpfpm-php83.serviceConfig.ProtectHome = lib.mkForce false;
      phpfpm-php85.serviceConfig.ProtectHome = lib.mkForce false;
    };

    services.phpfpm.pools = {
      php83 = mkPhpPool pkgs.php83;
      php85 = mkPhpPool pkgs.php85;
    };
  };
}
