{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.apps.browser;
  isLowspec = osConfig.nixos.lowspec.enable;
in
{
  config = lib.mkIf (cfg.enable && cfg.brave.enable) {
    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      nativeMessagingHosts = [
        pkgs.kdePackages.plasma-browser-integration
      ];

      extensions = [
        { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # Plasma Browser Integration
        { id = "fopaemeedckajflibkpifppcankfmbhk"; } # Alpine.js DevTools
        { id = "omghfjlpggmjjaagoclmmobgdodcjboh"; } # Browsec VPN
      ];

      commandLineArgs = [
        "--disable-metrics"
        "--no-first-run"
        "--no-default-browser-check"
      ]
      ++ (lib.optionals isLowspec [
        "--disable-background-networking"
        "--disable-background-timer-throttling"
        "--disable-backgrounding-occluded-windows"
        "--enable-features=AutomaticTabDiscarding,DiscardRingImprovements"
        "--disable-gpu-vsync"
        "--disable-smooth-scrolling"
        "--disable-breakpad"
        "--disable-component-update"
      ]);
    };
  };
}
