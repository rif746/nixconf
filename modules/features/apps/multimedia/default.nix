{ ... }: {
    # Otomatis terdaftar ke self.homeModules.apps-multimedia via flake-parts
    flake.homeModules.apps-multimedia = { config, lib, pkgs, ... }: let
        cfg = config.features.apps.multimedia;
    in {
        options.features.apps.multimedia.enable = lib.mkEnableOption "Multimedia application suite";

        config = lib.mkIf cfg.enable {
            home.packages = with pkgs;[
                haruna
                mpv
            ];
        };
    };
}
