{ ... }: {
  flake.nixosModules.cli-git = { pkgs, ... }: {
    # Konfigurasi Git via Home-Manager untuk user syarif
    home-manager.users.syarif = {
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
  };
}
