{ config, lib, ... }:
let
  cfg = config.features.cli.developer;
in
{
    config = lib.mkIf (cfg.enable && cfg.direnv.enable) {
        programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
            enableFishIntegration = true;
            silent = true;
        };
    };
}
