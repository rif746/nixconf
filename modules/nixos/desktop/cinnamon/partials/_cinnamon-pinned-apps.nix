{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nixos.desktop.cinnamon;

  baseLaunchers = [
    "nemo.desktop"
    "org.gnome.Terminal.desktop"
    "cinnamon-settings.desktop"
  ];

  pinnedApps = baseLaunchers ++ config.nixos.desktop.optionalLaunchers;

  groupedWindowListSchema = "${pkgs.cinnamon}/share/cinnamon/applets/grouped-window-list@cinnamon.org/settings-schema.json";

  groupedWindowListConfig =
    pkgs.runCommand "grouped-window-list-2.json"
      {
        nativeBuildInputs = [ pkgs.jq ];
        pinnedJson = builtins.toJSON pinnedApps;
      }
      ''
        SCHEMA_MD5=$(md5sum ${groupedWindowListSchema} | cut -d' ' -f1)
        jq --argjson pinned "$pinnedJson" --arg md5 "$SCHEMA_MD5" '
          .["pinned-apps"].value = $pinned |
          .["__md5__"] = $md5
        ' ${groupedWindowListSchema} > $out
      '';
in
{
  config = lib.mkIf cfg.enable {
    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings."org/cinnamon" = {
            favorite-apps = pinnedApps;
          };
        }
      ];
    };

    systemd.user.tmpfiles.rules = [
      "d %h/.config/cinnamon/spices/grouped-window-list@cinnamon.org 0755 - - -"
      "L+ %h/.config/cinnamon/spices/grouped-window-list@cinnamon.org/2.json - - - - ${groupedWindowListConfig}"
    ];
  };
}
