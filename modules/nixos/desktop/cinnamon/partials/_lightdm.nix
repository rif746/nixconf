{
  config,
  lib,
  ...
}:
let
  cfg = config.nixos.desktop.cinnamon;
in
{
  config = lib.mkIf cfg.enable {
    services.xserver.displayManager.lightdm = {
      enable = true;
      # Tema dan background otomatis diinjeksi oleh stylix.targets.lightdm
      greeters.slick.enable = true;
    };
  };
}
