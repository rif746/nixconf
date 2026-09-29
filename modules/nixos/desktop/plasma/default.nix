{ ... }: {
  flake.nixosModules.desktop-plasma =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      # Skrip Bash untuk mendeteksi ID D-Bus secara dinamis & apply preset
      loadPanelColorizerPreset = pkgs.writeShellScriptBin "apply-panel-colorizer" ''
        sleep 3

        DBUS_SERVICE=$(qdbus | grep colorizer)

        echo "$DBUS_SERVICE" | while read -r SERVICE; do
            qdbus "$SERVICE" /preset preset ~/.config/panel-colorizer/presets/MyWidgets
        done
      '';

      kVitals = pkgs.callPackage ./extensions/applets/_kvitals.nix { };

      # 1. Aplikasi Dasar (Selalu Dipin)
      baseLaunchers = [
        "applications:org.kde.dolphin.desktop"
        "applications:org.kde.konsole.desktop"
        "applications:systemsettings.desktop"
      ];

      # 2. Dari Sesama Modul Home Manager (Gunakan `config`)
      firefoxLauncher = lib.optional (
        config.home-manager.users.syarif.features.apps.browser.enable or false
        && config.home-manager.users.syarif.features.apps.browser.firefox.enable or false
      ) "applications:firefox.desktop";

      braveLauncher = lib.optional (
        config.home-manager.users.syarif.features.apps.browser.enable or false
        && config.home-manager.users.syarif.features.apps.browser.brave.enable or false
      ) "applications:brave-browser.desktop";

      communicationLauncher =
        lib.optional (config.home-manager.users.syarif.features.apps.communication.enable or false)
          "applications:ferdium.desktop";

      # 3. Dari Modul NixOS System (Gunakan `osConfig`)
      steamLauncher = lib.optional (config.modules.gaming.enable or false) "applications:steam.desktop";
    in
    {
      services.xserver.enable = true;
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;

      environment.systemPackages = with pkgs; [
        qdiskinfo
        kdePackages.filelight
      ];

      programs.partition-manager.enable = true;

      home-manager.users.syarif = {

        home.packages = with pkgs; [
          plasma-panel-colorizer
          kVitals
          (python314.withPackages (
            ps: with ps; [
              dbus-python
              pygobject3
            ]
          ))
        ];

        xdg.configFile."panel-colorizer/presets/MyWidgets/settings.json".source =
          ./panel-colorizer-settings.json;

        xdg.configFile."autostart/load-panel-preset.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Load Panel Colorizer Preset
          Exec=${loadPanelColorizerPreset}/bin/apply-panel-colorizer
          Hidden=false
          NoDisplay=true
          X-KDE-AutostartScript=true
        '';

        programs.plasma = {
          enable = true;

          workspace = {
            clickItemTo = "select";
            lookAndFeel = "org.kde.breezedark.desktop";
          };

          panels = [
            {
              location = "top";
              height = 36;
              widgets = [
                {
                  name = "org.kde.plasma.kickoff";
                  config = {
                    General.icon = "nix-snowflake";
                  };
                }
                "org.kde.plasma.panelspacer"
                "org.kde.plasma.kvitals"
                "org.kde.plasma.panelspacer"
                "org.kde.plasma.systemtray"
                {
                  digitalClock = {
                    date.format = "shortDate";
                    date.position = "besideTime";
                    settings = {
                      Appearance.showDate = false;
                    };
                  };
                }
                {
                  name = "luisbocanegra.panel.colorizer";
                  config = {
                    General = {
                      enable = true;
                      hideWidget = true;
                      pluginFound=true;
                    };
                  };
                }
              ];
            }
            {
              location = "bottom";
              height = 52;
              lengthMode = "fit";
              hiding = "dodgewindows";
              floating = true;
              widgets = [
                {
                  iconTasks = {
                    launchers =
                      baseLaunchers ++ firefoxLauncher ++ braveLauncher ++ communicationLauncher ++ steamLauncher;
                  };
                }
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
