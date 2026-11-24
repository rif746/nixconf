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
    services.picom = {
      enable = true;
      backend = "glx";
      vSync = true;

      settings = {
        blur = {
          method = "dual_kawase";
          strength = 6;
          background = true;
          background-frame = false;
          background-fixed = false;
        };

        blur-background-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "class_g = 'Cinnamon'"
          "_GTK_FRAME_EXTENTS@"
        ];

        corner-radius = 8;
        rounded-corners-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
        ];

        shadow = true;
        shadow-radius = 12;
        shadow-opacity = 0.45;
        shadow-exclude = [
          "name = 'Notification'"
          "class_g = 'Cinnamon'"
          "_GTK_FRAME_EXTENTS@"
        ];

        fading = true;
        fade-in-step = 0.04;
        fade-out-step = 0.04;
        use-damage = true;
      };
    };
  };
}
