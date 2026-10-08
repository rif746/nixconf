{ ... }: {
  # Otomatis terdaftar ke self.homeModules.apps-jetbrains via flake-parts & import-tree
  flake.homeModules.apps-jetbrains = { config, lib, pkgs, ... }: let
    cfg = config.features.apps.jetbrains;
  in {
    options.features.apps.jetbrains = {
      enable = lib.mkEnableOption "JetBrains IDEs and Android Studio suite";

      # Sub-toggle (Default false agar IDE berat tidak terinstall sekaligus kecuali diaktifkan)
      android-studio.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Android Studio IDE";
      };
      phpstorm.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "JetBrains PhpStorm IDE";
      };
      goland.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "JetBrains GoLand IDE";
      };
      datagrip.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "JetBrains DataGrip Database IDE";
      };
      pycharm.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "JetBrains PyCharm Professional IDE";
      };
    };

    config = lib.mkIf cfg.enable {
      home.packages = with pkgs;
        (lib.optional cfg.android-studio.enable android-studio) ++
        (lib.optional cfg.phpstorm.enable jetbrains.phpstorm) ++
        (lib.optional cfg.goland.enable jetbrains.goland) ++
        (lib.optional cfg.datagrip.enable jetbrains.datagrip) ++
        (lib.optional cfg.pycharm.enable jetbrains.pycharm-professional);
    };
  };
}
