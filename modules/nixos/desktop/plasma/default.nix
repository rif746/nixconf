{ ... }: {
  flake.nixosModules.desktop-plasma =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      kVitals = pkgs.callPackage ./extensions/applets/_kvitals.nix { };

      baseLaunchers = [
        "applications:org.kde.dolphin.desktop"
        "applications:org.kde.konsole.desktop"
        "applications:systemsettings.desktop"
      ];

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

      androidStudioLauncher =
        lib.optional (config.home-manager.users.syarif.features.apps.jetbrains.android-studio.enable or false)
          "applications:android-studio.desktop";

      phpStormLauncher =
        lib.optional (config.home-manager.users.syarif.features.apps.jetbrains.phpstorm.enable or false)
          "applications:phpstorm.desktop";

      pycharmLauncher =
        lib.optional (config.home-manager.users.syarif.features.apps.jetbrains.pycharm.enable or false)
          "applications:pycharm.desktop";

      datagripLauncher =
        lib.optional (config.home-manager.users.syarif.features.apps.jetbrains.datagrip.enable or false)
          "applications:datagrip.desktop";

      golandLauncher =
        lib.optional (config.home-manager.users.syarif.features.apps.jetbrains.goland.enable or false)
          "applications:goland.desktop";

      steamLauncher = lib.optional (config.modules.gaming.enable or false) "applications:steam.desktop";
    in
    {
      services.xserver.enable = true;
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;

      environment = {

        systemPackages = with pkgs; [
          qdiskinfo
          kdePackages.filelight
        ];
      };

      programs.partition-manager.enable = true;

      home-manager.users.syarif = {
        home = {
          file.".local/share/icons/default" = {
            source = "${pkgs.kdePackages.breeze}/share/icons/breeze_cursors/";
            recursive = true;
          };

          packages = with pkgs; [
            plasma-panel-colorizer
            kVitals
            (python314.withPackages (
              ps: with ps; [
                dbus-python
                pygobject3
              ]
            ))
          ];
        };

        xdg.configFile."panel-colorizer/presets/My Rubik/settings.json".source =
          ./panel-colorizer-settings.json;

        programs.plasma = {
          enable = true;
          overrideConfig = true;

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
                      enabled = true;
                      hideWidget = true;
                      pluginFound=true;
                      presetAutoloading = builtins.toJSON {
                        enable = true;
                        normal = "${pkgs.plasma-panel-colorizer}/share/plasma/plasmoids/luisbocanegra.panel.colorizer/contents/ui/presets/Transparent";
                        touchingWindow = "/home/syarif/.config/panel-colorizer/presets/My Rubik";
                      };
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
                      baseLaunchers
                      ++ firefoxLauncher
                      ++ braveLauncher
                      ++ communicationLauncher
                      ++ steamLauncher
                      ++ androidStudioLauncher
                      ++ phpStormLauncher
                      ++ datagripLauncher
                      ++ pycharmLauncher
                      ++ golandLauncher;
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
