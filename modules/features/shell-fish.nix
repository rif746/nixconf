{ self, ... }: {
  flake.nixosModules.fish = { pkgs, ... }: {
    # 1. Enable Fish shell system-wide
    programs.fish = {
      enable = true;

      # Define shell aliases
      shellAliases = {
        ll = "ls -l";
        la = "ls -la";
        g = "git";
        rebuild = "sudo nixos-rebuild switch";
      };

      # Custom Fish abbreviations (expands automatically as you type)
      shellAbbrs = {
        gs = "git status";
        ga = "git add";
        gc = "git commit";
      };

      # Custom functions or raw Fish script executed on interactive shell start
      interactiveShellInit = ''
        set -g fish_greeting "" # Disable default welcome greeting
      '';
    };

    # 2. Set Fish as the default shell for your user
    users.users."syarif".shell = pkgs.fish;
  };
}
