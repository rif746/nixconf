{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.apps.browser;
in
{
  config = lib.mkIf (cfg.enable && cfg.firefox.enable) {
    stylix.targets.firefox = {
      profileNames = [ "default" ];
      colorTheme.enable = true;
    };

    programs.firefox = {
      enable = true;
      languagePacks = [
        "id"
        "en-US"
      ];

      profiles.default = {
        extensions.force = true;
      };

      nativeMessagingHosts = [
        pkgs.kdePackages.plasma-browser-integration
      ];

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
          "FirefoxColor@mozilla.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/3643624/latest.xpi";
            installation_mode = "force_installed";
          };
        };

        Preferences = {
          "browser.contentblocking.category" = {
            Value = "strict";
            Status = "locked";
          };
          "extensions.pocket.enabled" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = {
            Value = false;
            Status = "locked";
          };
          "security.enterprise_roots.enabled" = true;

          # AI Features Disabled
          "browser.ai.control.default" = {
            Value = "blocked";
            Status = "locked";
          };
          "browser.ai.control.linkPreviewKeyPoints" = {
            Value = "blocked";
            Status = "locked";
          };
          "browser.ai.control.pdfjsAltText" = {
            Value = "blocked";
            Status = "locked";
          };
          "browser.ai.control.sidebarChatbot" = {
            Value = "blocked";
            Status = "locked";
          };
          "browser.ai.control.smartTabGroups" = {
            Value = "blocked";
            Status = "locked";
          };
          "browser.ai.control.smartWindow" = {
            Value = "blocked";
            Status = "locked";
          };
          "browser.ai.control.translations" = {
            Value = "blocked";
            Status = "locked";
          };
          "browser.toolbars.bookmarks.visibility" = {
            Value = "never";
            Status = "locked";
          };

          # Sidebar & Vertical Tabs
          "sidebar.revamp" = {
            Value = true;
            Status = "locked";
          };
          "sidebar.verticalTabs" = {
            Value = true;
            Status = "locked";
          };
          "sidebar.visibility" = {
            Value = "always-show";
            Status = "locked";
          };
          "sidebar.main.tools" = {
            Value = "history,bookmarks,passwords";
            Status = "locked";
          };

          # Custom Toolbar Placement Layout
          "browser.uiCustomization.state" = {
            Value = builtins.toJSON {
              placements = {
                widget-overflow-fixed-list = [ ];
                unified-extensions-area = [
                  "helper_savefrom_net-browser-action"
                  "plasma-browser-integration_kde_org-browser-action"
                  "browsec_browsec_com-browser-action"
                ];
                nav-bar = [
                  "sidebar-button"
                  "back-button"
                  "forward-button"
                  "stop-reload-button"
                  "urlbar-container"
                  "unified-extensions-button"
                  "downloads-button"
                  "ublock0_raymondhill_net-browser-action"
                  "panel-menu-button"
                ];
                toolbar-menubar = [ "menubar-items" ];
                TabsToolbar = [ ];
                vertical-tabs = [ "tabbrowser-tabs" ];
                PersonalToolbar = [
                  "import-button"
                  "personal-bookmarks"
                ];
              };
              seen = [
                "developer-button"
                "helper_savefrom_net-browser-action"
                "plasma-browser-integration_kde_org-browser-action"
                "browsec_browsec_com-browser-action"
                "ublock0_raymondhill_net-browser-action"
                "downloads-button"
              ];
              dirtyAreaCache = [
                "nav-bar"
                "TabsToolbar"
                "vertical-tabs"
                "PersonalToolbar"
                "unified-extensions-area"
                "toolbar-menubar"
              ];
              currentVersion = 28;
              newElementCount = 0;
            };
            Status = "user";
          };
        };
      };
    };
  };
}
