{ user, cfg }:
{ lib, pkgs, ... }:
{
  config = lib.mkIf cfg.golang.enable {
    environment = {
      systemPackages = with pkgs; [
        go
        gopls
        delve
        golangci-lint
        gotools
      ];

      sessionVariables = {
        GOPATH = "/home/${user.name}/.config/go";
        GOBIN = "/home/${user.name}/.config/go/bin";
        PATH = [
          "/home/${user.name}/.config/go/bin"
        ];
      };
    };
  };
}
