{ ... }: {
  flake.homeModules.cli-git =
    { config, lib, ... }:
    let
      cfg = config.features.cli.vcs;
    in
    {
      options.features.cli.vcs = {
        enable = lib.mkEnableOption "Version Control System tools (Git, LazyGit, GitHub CLI)";

        git.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Git configuration";
        };

        lazygit.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable LazyGit TUI client";
        };

        gh.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable GitHub CLI";
        };
      };

      config = lib.mkIf cfg.enable {
        programs.git = lib.mkIf cfg.git.enable {
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

        programs.lazygit = lib.mkIf cfg.lazygit.enable {
          enable = true;
        };

        programs.gh = lib.mkIf cfg.gh.enable {
          enable = true;
          settings = {
            git_protocol = "ssh";
          };
        };
      };
    };
}
