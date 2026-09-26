# modules/features/cli/fish.nix
{ ... }: {
  flake.nixosModules.cli-fish = { pkgs, ... }: {
    programs.fish.enable = true;

    home-manager.users.syarif = {
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
  };
}
