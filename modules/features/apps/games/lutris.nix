{ ... }: {
  flake.homeModules.apps-lutris =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.apps.lutris;
    in
    {
      options.features.apps.lutris = {
        enable = lib.mkEnableOption "Lutris game launcher with custom Wine/Proton";

        useProtonGE = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Use proton-ge-bin as default Wine package for Lutris";
        };
      };

      config = lib.mkIf cfg.enable {
        programs.lutris = {
          enable = true;
          defaultWinePackage = lib.mkIf cfg.useProtonGE pkgs.proton-ge-bin;
        };

        home.packages = with pkgs; [
          protonup-qt
          mangohud
        ];
      };
    };
}
