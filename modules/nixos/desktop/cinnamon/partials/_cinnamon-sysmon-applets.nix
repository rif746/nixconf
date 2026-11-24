{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nixos.desktop.cinnamon;
  isDark = config.stylix.polarity == "dark";

  customApplets = pkgs.callPackage ../extensions/_applets.nix { };
  inherit (customApplets) sysmonUuid;

  colors = config.lib.stylix.colors.withHashtag or { };
  cText = colors.base05 or "#ffffff";
  cMuted = colors.base04 or "#7f849c";
  cGreen = colors.base0B or "#2CFF2C";
  cYellow = colors.base0A or "#ffff00";
  cOrange = colors.base09 or "#FFA500";
  cRed = colors.base08 or "#FF4500";

  iconVariant = if isDark then "white" else "black";
  sysmonIconDir = "/run/current-system/sw/share/cinnamon/applets/${sysmonUuid}/icons";
  sysmonSchema = "${customApplets}/share/cinnamon/applets/${sysmonUuid}/settings-schema.json";

  sysmonValues = {
    "show-cpu" = true;
    "cpu-label-text" = "CPU";
    "cpu-symbol" = "${sysmonIconDir}/cpu_${iconVariant}.svg";
    "cpu-display-percentage" = true;
    "cpu-low" = 50;
    "cpu-med" = 75;
    "cpu-high" = 85;
    "cpu-enable-colors" = true;
    "cpu-color-low" = cText;
    "cpu-color-med" = cYellow;
    "cpu-color-high" = cOrange;
    "cpu-color-critical" = cRed;

    "show-temp" = true;
    "show-celsius-symbol" = true;
    "temp-label-text" = "TEMP";
    "temp-symbol" = "${sysmonIconDir}/temp_${iconVariant}.svg";
    "temp-unit" = 0;
    "temp-low" = 55;
    "temp-med" = 70;
    "temp-high" = 85;
    "temp-enable-colors" = true;
    "temp-color-low" = cGreen;
    "temp-color-med" = cYellow;
    "temp-color-high" = cOrange;
    "temp-color-critical" = cRed;

    "show-ram" = true;
    "ram-label-text" = "RAM";
    "ram-symbol" = "${sysmonIconDir}/ram_${iconVariant}.svg";
    "ram-display-percentage" = true;
    "ram-display-mode" = 0;
    "ram-low" = 50;
    "ram-med" = 75;
    "ram-high" = 85;
    "ram-enable-colors" = true;
    "ram-color-low" = cText;
    "ram-color-med" = cYellow;
    "ram-color-high" = cOrange;
    "ram-color-critical" = cRed;

    "show-swap" = true;
    "swap-label-text" = "SWAP";
    "swap-symbol" = "${sysmonIconDir}/swap_${iconVariant}.svg";
    "swap-only-when-used" = true;
    "swap-display-percentage" = true;
    "swap-display-mode" = 0;
    "swap-low" = 30;
    "swap-med" = 60;
    "swap-high" = 80;
    "swap-enable-colors" = true;
    "swap-color-low" = cText;
    "swap-color-med" = cYellow;
    "swap-color-high" = cOrange;
    "swap-color-critical" = cRed;

    "cpu-order" = 1;
    "temp-order" = 2;
    "ram-order" = 3;
    "swap-order" = 4;

    "update-interval" = 1000;
    "enable-separator" = true;
    "separator-text" = "•";
    "separator-color" = cMuted;
    "display-percentage" = true;

    "profile-1-name" = "Slot 1 (Standard)";
    "profile-2-name" = "Slot 2 (Empty)";
    "profile-2-data" = "{}";
    "profile-3-name" = "Slot 3 (Empty)";
    "profile-3-data" = "{}";
    "profile-message-duration" = 5;
  };

  sysmonProfile1Json = builtins.toJSON (sysmonValues // { "profile-1-data" = "{}"; });

  sysmonConfig =
    pkgs.runCommand "combined-monitor-11.json"
      {
        nativeBuildInputs = [ pkgs.jq ];
        valuesJson = builtins.toJSON (sysmonValues // { "profile-1-data" = sysmonProfile1Json; });
      }
      ''
        SCHEMA_MD5=$(md5sum ${sysmonSchema} | cut -d' ' -f1)
        jq --argjson vals "$valuesJson" --arg md5 "$SCHEMA_MD5" '
          reduce ($vals | keys_unsorted[]) as $k (.; .[$k].value = $vals[$k]) |
          .["__md5__"] = $md5
        ' ${sysmonSchema} > $out
      '';
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d %h/.config/cinnamon/spices/${sysmonUuid} 0755 - - -"
      "L+ %h/.config/cinnamon/spices/${sysmonUuid}/11.json - - - - ${sysmonConfig}"
    ];
  };
}
