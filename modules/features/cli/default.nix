{ ... }: {
  # Terdaftar otomatis ke self.homeModules.cli-developer via flake-parts & import-tree
  flake.homeModules.cli-developer = { config, lib, pkgs, ... }: let
    cfg = config.features.cli.developer;
  in {
    imports = [
      ./partials/_fish.nix
      ./partials/_git.nix
      ./partials/_nvim.nix
      ./partials/_direnv.nix
    ];

    options.features.cli.developer = {
      enable = lib.mkEnableOption "Developer CLI toolchain (Fish, Git, Neovim, Direnv)";

      fish.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Fish Shell";
      };
      git.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Git Version Control";
      };
      nvim.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Neovim Text Editor";
      };
      direnv.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Direnv environment switcher";
      };
    };
  };
}
