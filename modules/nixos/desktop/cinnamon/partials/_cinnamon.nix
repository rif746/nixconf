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

  # Paket tema Catppuccin GTK lengkap (GTK2, GTK3, GTK4, Metacity, & Cinnamon Shell)
  variant = if isDark then "mocha" else "latte";
  accent = "blue";
  size = "standard";

  themePkg = pkgs.catppuccin-gtk.override {
    accents = [ accent ];
    size = size;
    variant = variant;
  };
  themeName = "catppuccin-${variant}-${accent}-${size}";
in
{
  config = lib.mkIf cfg.enable {
    services.xserver.desktopManager.cinnamon = {
      enable = true;
    };

    # Matikan target GTK bawaan Stylix agar tidak menimpa tema GTK dengan paket tanpa dukungan Cinnamon
    stylix.targets.gtk.enable = lib.mkForce false;

    environment.systemPackages = with pkgs; [
      themePkg
      papirus-icon-theme
      adwaita-icon-theme
      librsvg
    ];

    environment.pathsToLink = [
      "/share/themes"
      "/share/icons"
    ];

    # Sinkronkan LightDM agar memakai tema Catppuccin GTK & ikon yang sama
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
          locks = [
            "/org/cinnamon/desktop/background/picture-uri"
            "/org/cinnamon/desktop/background/picture-options"
            "/org/cinnamon/desktop/interface/gtk-theme"
            "/org/cinnamon/desktop/interface/icon-theme"
            "/org/cinnamon/desktop/interface/color-scheme"
            "/org/x/apps/portal/color-scheme"
            "/org/gnome/desktop/interface/color-scheme"
            "/org/cinnamon/theme/name"
            "/org/cinnamon/desktop/effects/desktop-effects"
          ];

          settings = {
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

            # Shell Cinnamon memakai tema Catppuccin yang sama
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
