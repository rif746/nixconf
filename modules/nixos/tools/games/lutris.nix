{ ... }: {
  flake.homeModules.apps-lutris =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    let
      # Cek apakah modul gaming utama aktif
      gamingEnabled = osConfig.nixos.tools.gaming.enable or false;

      # Cek opsi withExtraTools dari modul gaming.steam
      extraToolsEnabled = osConfig.nixos.tools.gaming.steam.withExtraTools or false;

      # Gabungkan kedua kondisi
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
