{ ... }: {
  flake.nixosModules.apps-firefox = { pkgs, ... }: {
    programs.firefox = {
      enable = true;
      languagePacks = [ "id" "en-US" ];

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

          "helper@savefrom.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4994239/latest.xpi";
            installation_mode = "force_installed";
          };

          "browsec@browsec.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4888986/latest.xpi";
            installation_mode = "force_installed";
          };
        };

        Preferences = {
          "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
          "extensions.pocket.enabled" = { Value = false; Status = "locked"; };

          "browser.ai.control.default" = { Value = "blocked"; Status = "locked"; };
          "browser.ai.control.linkPreviewKeyPoints" = { Value = "blocked"; Status = "locked"; };
          "browser.ai.control.pdfjsAltText" = { Value = "blocked"; Status = "locked"; };
          "browser.ai.control.sidebarChatbot" = { Value = "blocked"; Status = "locked"; };
          "browser.ai.control.smartTabGroups" = { Value = "blocked"; Status = "locked"; };
          "browser.ai.control.smartWindow" = { Value = "blocked"; Status = "locked"; };
          "browser.ai.control.translations" = { Value = "blocked"; Status = "locked"; };
          "browser.toolbars.bookmarks.visibility" = { Value = "never"; Status = "locked"; };

          "sidebar.revamp" = { Value = true; Status = "locked"; };
          "sidebar.verticalTabs" = { Value = true; Status = "locked"; };
          "sidebar.visibility" = { Value = "always-show"; Status = "locked"; };
          "sidebar.main.tools" = { Value = "history,bookmarks,passwords"; Status = "locked"; };
        };
      };
    };
  };
}
