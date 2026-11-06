{ ... }: {
  flake.nixosModules.desktop-plasma =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.nixos.desktop.plasma;
    in
    {
      options.nixos.desktop.plasma = {
        enable = lib.mkEnableOption "KDE Plasma 6 Desktop Environment";
      };

      config = lib.mkIf cfg.enable {
        services = {
          xserver.enable = true;
          displayManager.plasma-login-manager.enable = true;
          desktopManager.plasma6.enable = true;
        };

        environment = {
          systemPackages = with pkgs; [
            qdiskinfo
            ctags
            kdePackages.filelight
          ];
        };

        programs = {
          partition-manager.enable = true;
          kde-pim.enable = false;
        };
      };
    };
}
