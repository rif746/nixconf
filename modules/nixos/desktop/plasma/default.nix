{ ... }: {
  flake.nixosModules.desktop-plasma = { pkgs, ... }: {
    # 1. Aktifkan Plasma 6 di tingkat NixOS
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    # 2. Pengaturan Plasma via Home-Manager & Plasma-Manager
    home-manager.users.syarif = {
      programs.plasma = {
        enable = true;

        # Pengaturan Tema & Tampilan
        workspace = {
          clickItemTo = "select";
          lookAndFeel = "org.kde.breezedark.desktop";
        };

        # Konfigurasi Panel Utama (Taskbar Bawah)
        panels = [
          {
            location = "bottom";
            height = 38;
            minLength = null;
            maxLength = null;
            widgets = [
              # Menu Aplikasi Kickoff
              {
                name = "org.kde.plasma.kickoff";
                config = {
                  General.icon = "nix-snowflake";
                };
              }
              # Icon-only Task Manager
              "org.kde.plasma.icontasks"
              # Margins Separator
              "org.kde.plasma.marginsseparator"
              # System Tray (Baterai, Wifi, Suara)
              "org.kde.plasma.systemtray"
              # Jam Digital
              "org.kde.plasma.digitalclock"
            ];
          }
        ];

        session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

        # Custom Keybindings / Shortcuts
        shortcuts = {
          "ksmserver"."Lock Session" = "Meta+L";
          "org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Meta+Shift+S";
        };

        configFile = {
          "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
          "dolphinrc"."General"."RememberOpenedTabs" = false;
          "dolphinrc"."MainWindow"."MenuBar" = "Enabled";
          "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft" = "SF";
          "kwinrc"."Desktops"."Number" = {
            value = 8;
            # Forces kde to not change this value (even through the settings app).
            immutable = true;
          };
        };
      };

      programs.konsole = {
        enable = true;
        defaultProfile = "Default";

        profiles = {
          "Default" = {
            name = "Default";
            command = "/bin/sh -c $SHELL";
            font = {
              name = "fira-code-symbols";
              size = 10;
            };
          };
        };
      };
    };
  };
}
