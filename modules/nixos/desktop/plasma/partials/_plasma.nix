{
  config,
  pkgs,
  ...
}:
let
  kVitals = pkgs.callPackage ../extensions/applets/_kvitals.nix { };

  baseLaunchers = [
    "applications:org.kde.dolphin.desktop"
    "applications:org.kde.konsole.desktop"
    "applications:systemsettings.desktop"
  ];
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
              launchers = baseLaunchers ++ map (d: "applications:${d}") config.features.desktop.optionalLaunchers;
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
      "kwinrc"."TabBox"."MultiScreenMode" = 1;
      "kwinrc"."TabBox"."ShowOnActiveScreen" = true;
      "kwinrc"."TabBoxAlternative"."MultiScreenMode" = 1;
      "kwinrc"."TabBoxAlternative"."ShowOnActiveScreen" = true;
    };
  };
}
