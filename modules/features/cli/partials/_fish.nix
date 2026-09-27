{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.features.cli.developer;
in
{
    config = lib.mkIf (cfg.enable && cfg.fish.enable) {
        programs.fish = {
            enable = true;

            interactiveShellInit = ''
            set -g fish_greeting ""
            '';

            shellAliases = {
                rebuild = "sudo nixos-rebuild switch";
                nix-clear = "sudo nix-collect-garbage";
                c = "clear";
                g = "git";
                gs = "git status";
            };

            shellAbbrs = {
                ga = "git add";
                gc = "git commit -m";
                gp = "git push";
                gpl = "git pull";
            };

            plugins = [
                {
                    name = "z";
                    src = pkgs.fishPlugins.z.src;
                }
                {
                    name = "colored-man-pages";
                    src = pkgs.fishPlugins.colored-man-pages.src;
                }
            ];
        };

        # Prompt Starship
        programs.starship = {
            enable = true;
            enableFishIntegration = true;
        };
    };
}
