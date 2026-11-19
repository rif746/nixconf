{
  user,
  cfg,
  certDir,
}:
{ lib, pkgs, ... }:
let
  apacheConf = pkgs.replaceVars ../templates/apache.conf {
    certDir = "${certDir}";
    userName = user.name;
    mailpitDomain = cfg.mailpitDomain;
  };
in
{
  config = lib.mkIf cfg.enable {
    services.httpd = {
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

      extraConfig = builtins.readFile apacheConf;
    };
  };
}
