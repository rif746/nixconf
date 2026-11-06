{
  config,
  pkgs,
  lib,
  osConfig ? { },
  ...
}:
let
  kVitals = pkgs.callPackage ../extensions/applets/_kvitals.nix { };

  baseLaunchers = [
    "applications:org.kde.dolphin.desktop"
    "applications:org.kde.konsole.desktop"
    "applications:systemsettings.desktop"
  ];

  firefoxLauncher = lib.optional (
    config.features.apps.browser.enable or false && config.features.apps.browser.firefox.enable or false
  ) "applications:firefox.desktop";

  braveLauncher = lib.optional (
    config.features.apps.browser.enable or false && config.features.apps.browser.brave.enable or false
  ) "applications:brave-browser.desktop";

  communicationLauncher = lib.optional (config.features.apps.communication.enable or false
  ) "applications:ferdium.desktop";

  androidStudioLauncher = lib.optional (config.features.apps.jetbrains.android-studio.enable or false
  ) "applications:android-studio.desktop";

  phpStormLauncher = lib.optional (config.features.apps.jetbrains.phpstorm.enable or false
  ) "applications:phpstorm.desktop";

  pycharmLauncher = lib.optional (config.features.apps.jetbrains.pycharm.enable or false
  ) "applications:pycharm.desktop";

  datagripLauncher = lib.optional (config.features.apps.jetbrains.datagrip.enable or false
  ) "applications:datagrip.desktop";

  golandLauncher = lib.optional (config.features.apps.jetbrains.goland.enable or false
  ) "applications:goland.desktop";

  steamLauncher = lib.optional (osConfig.modules.gaming.enable or false) "applications:steam.desktop";
in
{
  home = {
    packages = with pkgs; [
      plasma-panel-colorizer
      kVitals
    ];

  };

  xdg.configFile."panel-colorizer/presets/My Rubik/settings.json".source =
    ./panel-colorizer-settings.json;

  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace = {
      clickItemTo = "select";
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
                pluginFound = true;
                presetAutoloading = builtins.toJSON {
                  enable = true;
                  normal = "${config.home.homeDirectory}/.config/panel-colorizer/presets/My Rubik";
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
        immutable = true;
      };
    };
  };
}
