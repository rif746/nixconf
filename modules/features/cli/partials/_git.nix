{ config, lib, ... }:
let
  cfg = config.features.cli.developer;
in
{
    config = lib.mkIf (cfg.enable && cfg.git.enable) {
        programs.git = {
            enable = true;

            settings = {
                user = {
                    name = "Syarif Ubaidillah";
                    email = "ubed56pb@gmail.com";
                };
                init = {
                    defaultBranch = "master";
                };
                pull = {
                    rebase = true; # Merge on pull dengan rebase secara default
                };
                core = {
                    editor = "vim";
                };
            };
        };
    };
}
