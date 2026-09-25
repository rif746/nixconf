{ self, ... }: {
  flake.nixosModules.firefox = { pkgs, ... }: {
    programs.firefox = {
      enable = true;
      languagePacks = [ "de" "en-US" ];

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;

        ExtensionSettings = {
          "*".installation_mode = "blocked";

          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };

          "plasma-browser-integration@kde.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4614817/latest.xpi";
            installation_mode = "force_installed";
          };

          "@alpinejs-devtools-pro" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4848289/latest.xpi";
            installation_mode = "force_installed";
          };
        };

        Preferences = {
          "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
          "extensions.pocket.enabled" = { Value = false; Status = "locked"; };
        };
      };
    };
  };
}
