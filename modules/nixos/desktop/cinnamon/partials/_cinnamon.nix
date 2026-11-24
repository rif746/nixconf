{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nixos.desktop.cinnamon;
  isDark = config.stylix.polarity == "dark";
  colorScheme = if isDark then "prefer-dark" else "prefer-light";

  variant = if isDark then "mocha" else "latte";
  accent = "blue";
  size = "standard";

  themePkg = pkgs.catppuccin-gtk.override {
    accents = [ accent ];
    size = size;
    variant = variant;
  };
  themeName = "catppuccin-${variant}-${accent}-${size}";

  customApplets = pkgs.callPackage ../extensions/_applets.nix { };
  inherit (customApplets) sysmonUuid menuUuid;
in
{
  config = lib.mkIf cfg.enable {
    services.xserver.desktopManager.cinnamon.enable = true;

    # Matikan target GTK Stylix agar tema Catppuccin GTK lengkap (termasuk Cinnamon Shell) tidak tertimpa
    stylix.targets.gtk.enable = lib.mkForce false;

    environment.systemPackages = with pkgs; [
      themePkg
      papirus-icon-theme
      adwaita-icon-theme
      librsvg
    ];

    services.xserver.displayManager.lightdm.greeters.gtk = {
      theme = {
        name = lib.mkForce themeName;
        package = lib.mkForce themePkg;
      };
      iconTheme = {
        name = lib.mkForce "Papirus-Dark";
        package = lib.mkForce pkgs.papirus-icon-theme;
      };
    };

    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/cinnamon" = {
              panels-enabled = [ "1:0:bottom" ];

              enabled-applets = [
                "panel1:left:0:${menuUuid}:0"
                "panel1:left:1:show-desktop@cinnamon.org:1"
                "panel1:left:2:grouped-window-list@cinnamon.org:2"

                "panel1:right:0:${sysmonUuid}:11"
                "panel1:right:1:systray@cinnamon.org:3"
                "panel1:right:2:xapp-status@cinnamon.org:4"
                "panel1:right:3:notifications@cinnamon.org:5"
                "panel1:right:4:removable-drives@cinnamon.org:6"
                "panel1:right:5:network@cinnamon.org:7"
                "panel1:right:6:sound@cinnamon.org:8"
                "panel1:right:7:power@cinnamon.org:9"
                "panel1:right:8:calendar@cinnamon.org:10"
              ];
            };

            "org/cinnamon/desktop/background" = {
              picture-uri = "file://${toString config.stylix.image}";
              picture-options = "zoom";
            };

            "org/cinnamon/desktop/interface" = {
              gtk-theme = themeName;
              icon-theme = "Papirus-Dark";
              color-scheme = colorScheme;
            };

            "org/gnome/desktop/interface" = {
              color-scheme = colorScheme;
            };

            "org/x/apps/portal" = {
              color-scheme = colorScheme;
            };

            "org/cinnamon/theme" = {
              name = themeName;
            };

            "org/cinnamon/desktop/effects" = {
              desktop-effects = true;
            };
          };
        }
      ];
    };
  };
}
