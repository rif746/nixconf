{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nixos.desktop.cinnamon;

  hmUsers = config.home-manager.users or { };
  anyUserHas = pred: lib.any pred (lib.attrValues hmUsers);

  baseLaunchers = [
    "nemo.desktop"
    "org.gnome.Terminal.desktop"
    "cinnamon-settings.desktop"
  ];

  firefoxLauncher = lib.optional (
    anyUserHas (
      u: (u.features.apps.browser.enable or false) && (u.features.apps.browser.firefox.enable or false)
    )
  ) "firefox.desktop";

  braveLauncher = lib.optional (
    anyUserHas (
      u: (u.features.apps.browser.enable or false) && (u.features.apps.browser.brave.enable or false)
    )
  ) "brave-browser.desktop";

  communicationLauncher = lib.optional (
    anyUserHas (u: u.features.apps.communication.enable or false)
  ) "ferdium.desktop";

  androidStudioLauncher = lib.optional (
    anyUserHas (u: u.features.apps.jetbrains.android-studio.enable or false)
  ) "android-studio.desktop";

  phpStormLauncher = lib.optional (
    anyUserHas (u: u.features.apps.jetbrains.phpstorm.enable or false)
  ) "phpstorm.desktop";

  pycharmLauncher = lib.optional (
    anyUserHas (u: u.features.apps.jetbrains.pycharm.enable or false)
  ) "pycharm.desktop";

  datagripLauncher = lib.optional (
    anyUserHas (u: u.features.apps.jetbrains.datagrip.enable or false)
  ) "datagrip.desktop";

  golandLauncher = lib.optional (
    anyUserHas (u: u.features.apps.jetbrains.goland.enable or false)
  ) "goland.desktop";

  steamLauncher = lib.optional (
    config.modules.gaming.enable or false
  ) "steam.desktop";

  pinnedApps =
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

  # Bangun 2.json lengkap berdasarkan settings-schema.json resmi milik Cinnamon
  groupedWindowListConfig = pkgs.runCommand "grouped-window-list-2.json" {
    nativeBuildInputs = [ pkgs.jq ];
    pinnedJson = builtins.toJSON pinnedApps;
  } ''
    jq --argjson pinned "$pinnedJson" '
      .["pinned-apps"].value = $pinned
    ' ${pkgs.cinnamon}/share/cinnamon/applets/grouped-window-list@cinnamon.org/settings-schema.json > $out
  '';
in
{
  config = lib.mkIf cfg.enable {
    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          locks = [
            "/org/cinnamon/panels-enabled"
            "/org/cinnamon/enabled-applets"
            "/org/cinnamon/favorite-apps"
          ];

          settings = {
            "org/cinnamon" = {
              panels-enabled = [ "1:0:bottom" ];

              enabled-applets = [
                "panel1:left:0:menu@cinnamon.org:0"
                "panel1:left:1:show-desktop@cinnamon.org:1"
                "panel1:left:2:grouped-window-list@cinnamon.org:2"
                "panel1:right:0:systray@cinnamon.org:3"
                "panel1:right:1:xapp-status@cinnamon.org:4"
                "panel1:right:2:notifications@cinnamon.org:5"
                "panel1:right:3:removable-drives@cinnamon.org:6"
                "panel1:right:4:network@cinnamon.org:7"
                "panel1:right:5:sound@cinnamon.org:8"
                "panel1:right:6:power@cinnamon.org:9"
                "panel1:right:7:calendar@cinnamon.org:10"
              ];

              favorite-apps = pinnedApps;
            };
          };
        }
      ];
    };

    # Pasang symlink 2.json ke ~/.config/cinnamon/spices/grouped-window-list@cinnamon.org/2.json
    home-manager.sharedModules = [
      {
        xdg.configFile."cinnamon/spices/grouped-window-list@cinnamon.org/2.json" = {
          force = true;
          source = groupedWindowListConfig;
        };
      }
    ];
  };
}
