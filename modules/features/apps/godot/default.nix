{ ... }: {
  # Otomatis terdaftar ke self.homeModules.apps-godot via flake-parts & import-tree
  flake.homeModules.apps-godot = { config, lib, pkgs, ... }: let
    cfg = config.features.apps.godot;
  in {
    options.features.apps.godot = {
      enable = lib.mkEnableOption "Godot Engine for Game Creation";

      mono.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Godot Mono for C# Support";
      };
    };

    config = lib.mkIf cfg.enable {
      home.packages = with pkgs.godotPackages; [
        godot
      ] ++
        (lib.optional cfg.mono.enable godot-mono);
    };
  };
}
