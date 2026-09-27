{ config, lib, pkgs, ... }:

let
  cfg = config.features.apps.browser;
in {
  config = lib.mkIf (cfg.enable && cfg.brave.enable) {
    programs.chromium = {
      enable = true;
      package = pkgs.brave;

      extensions = [
        { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # Plasma Browser Integration
        { id = "fopaemeedckajflibkpifppcankfmbhk"; } # Alpine.js DevTools
        { id = "omghfjlpggmjjaagoclmmobgdodcjboh"; } # Browsec VPN
      ];

      # Flag command-line untuk mematikan fitur bloatware & fitur yang tidak diinginkan
      commandLineArgs = [
        "--disable-metrics"
        "--no-first-run"
        "--no-default-browser-check"
      ];
    };
  };
}
