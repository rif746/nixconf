{ cfg }:
{ lib, pkgs, ... }:
{
  config = lib.mkIf cfg.python.enable {
    environment.systemPackages = with pkgs; [
      python3
      uv
      ruff
      basedpyright
    ];
  };
}
