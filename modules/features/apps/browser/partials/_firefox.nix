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

        settings = {
            "browser.uiCustomization.state" = builtins.toJSON {
              placements = {
                widget-overflow-fixed-list = [ ];
                unified-extensions-area = [ ];
                nav-bar = [
                  "sidebar-button"
                  "back-button"
                  "forward-button"
                  "stop-reload-button"
                  "urlbar-container"
                  "unified-extensions-button"
                  "downloads-button"
                  "ublock0_raymondhill_net-browser-action"
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
                "ublock0_raymondhill_net-browser-action"
              ];
              dirtyAreaCache = [
                "nav-bar"
                "TabsToolbar"
                "PersonalToolbar"
                "unified-extensions-area"
                "toolbar-menubar"
              ];
              currentVersion = 28;
              newElementCount = 0;
          };
        };
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
            default_area = "navbar";
          };
          "plasma-browser-integration@kde.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4614817/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
          "@alpinejs-devtools-pro" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4848289/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
          "helper@savefrom.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4994239/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
          "browsec@browsec.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4888986/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
          "FirefoxColor@mozilla.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/3643624/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
        };

        Preferences = lib.mkMerge [
          (lib.mkIf isLowspec {
            "gfx.webrender.all" = {
              Value = true;
              Status = "default";
            };
            "media.ffmpeg.vaapi.enabled" = {
              Value = true;
              Status = "default";
            };
            "media.hardware-video-decoding.force-enabled" = {
              Value = true;
              Status = "default";
            };
            "dom.ipc.processCount" = {
              Value = 2;
              Status = "default";
            };

            "browser.tabs.unloadOnLowMemory" = {
              Value = true;
              Status = "default";
            };
            "browser.sessionstore.max_tabs_undo" = {
              Value = 2;
              Status = "default";
            };

            "datareporting.healthreport.uploadEnabled" = {
              Value = false;
              Status = "default";
            };
            "toolkit.telemetry.unified" = {
              Value = false;
              Status = "default";
            };
            "experiments.supported" = {
              Value = false;
              Status = "default";
            };
          })
          {
            "security.enterprise_roots.enabled" = true;

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
          }
        ];
      };
    };
  };
}
