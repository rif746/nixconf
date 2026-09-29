{ ... }: {
  flake.homeModules.apps-communication =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.apps.communication;
    in
    {
      options.features.apps.communication = {
        enable = lib.mkEnableOption "Communication application suite";

        ferdium.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Ferdium multi-service messaging app";
        };
        discord.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Discord Client";
        };
        slack.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Slack Client";
        };
        element.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Element Matrix Client";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages =
          with pkgs;
          (lib.optional cfg.ferdium.enable ferdium)
          ++ (lib.optional cfg.discord.enable discord)
          ++ (lib.optional cfg.slack.enable slack)
          ++ (lib.optional cfg.element.enable element-desktop);

        xdg.configFile = lib.mkMerge [
          (lib.mkIf cfg.ferdium.enable {
            "autostart/ferdium.desktop".source = "${pkgs.ferdium}/share/applications/ferdium.desktop";
          })
          (lib.mkIf cfg.discord.enable {
            "autostart/discord.desktop".source = "${pkgs.discord}/share/applications/discord.desktop";
          })
          (lib.mkIf cfg.slack.enable {
            "autostart/slack.desktop".source = "${pkgs.slack}/share/applications/slack.desktop";
          })
          (lib.mkIf cfg.element.enable {
            "autostart/element.desktop".source =
              "${pkgs.element-desktop}/share/applications/element-desktop.desktop";
          })
        ];
      };
    };
}
