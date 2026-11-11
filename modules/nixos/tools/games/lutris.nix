{ ... }: {
  flake.homeModules.apps-lutris =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    let
      # Check whether the main gaming module is enabled
      gamingEnabled = osConfig.nixos.tools.gaming.enable or false;

      # Check the withExtraTools option from the gaming.steam module
      extraToolsEnabled = osConfig.nixos.tools.gaming.steam.withExtraTools or false;

      # Combine both conditions
      enableLutris = gamingEnabled && extraToolsEnabled;
    in
    {
      config = lib.mkIf enableLutris {
        programs.lutris = {
          enable = true;
          defaultWinePackage = pkgs.proton-ge-bin;
        };

        home.packages = with pkgs; [
          protonup-qt
          mangohud
        ];
      };
    };
}
