{ ... }: {
  flake.homeModules.apps-browser = { config, lib, pkgs, ... }: let
    cfg = config.features.apps.browser;

    defaultDesktopFile =
      if cfg.default == "firefox" then "firefox.desktop"
      else if cfg.default == "brave" then "brave-browser.desktop"
      else "firefox.desktop";
  in {
    imports = [
      ./partials/_firefox.nix
      ./partials/_brave.nix
    ];

    options.features.apps.browser = {
      enable = lib.mkEnableOption "Browser suite with default browser wrapper";

      default = lib.mkOption {
        type = lib.types.enum [ "firefox" "brave" ];
        default = "firefox";
        description = "Default web browser for XDG MIME associations";
      };

      firefox.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Firefox browser";
      };

      brave.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Brave browser";
      };
    };

    # Wrapper XDG Default Browser
    config = lib.mkIf cfg.enable {
      home.sessionVariables = {
        BROWSER = cfg.default;
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = [ defaultDesktopFile ];
          "x-scheme-handler/http" = [ defaultDesktopFile ];
          "x-scheme-handler/https" = [ defaultDesktopFile ];
          "x-scheme-handler/about" = [ defaultDesktopFile ];
          "x-scheme-handler/unknown" = [ defaultDesktopFile ];
          "application/xhtml+xml" = [ defaultDesktopFile ];
        };
      };
    };
  };
}
