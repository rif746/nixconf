{ ... }: {
  flake.nixosModules.gaming =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.nixos.tools.gaming;
    in
    {
      options.nixos.tools.gaming = {
        enable = lib.mkEnableOption "Gaming environment (Steam, GameMode, Lutris, MangoHud)";

        steam.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Steam client and system-level integrations";
        };

        steam.useGameMode = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Feral GameMode optimization daemon";
        };

        steam.withExtraTools = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Lutris, ProtonUp-Qt, and MangoHud";
        };
      };

      config = lib.mkIf cfg.enable {
        programs.steam = lib.mkIf cfg.steam.enable {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
          protontricks.enable = true;
          gamescopeSession.enable = true;

          package = pkgs.steam.override {
            extraPkgs =
              pkgs: with pkgs; [
                noto-fonts
                noto-fonts-cjk-sans
                noto-fonts-color-emoji
              ];
          };

          fontPackages = with pkgs; [
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-color-emoji
          ];

          extraPackages =
            with pkgs;
            [ kdePackages.breeze ]
            ++ (lib.optional cfg.steam.withExtraTools protonup-qt)
            ++ (lib.optional cfg.steam.withExtraTools mangohud);
        };

        programs.gamemode.enable = cfg.steam.useGameMode;

        # CREATE NATIVE XDG AUTOSTART FOR STEAM
        systemd.user.services.steam-autostart = lib.mkIf cfg.steam.enable {
          description = "Start Steam automatically on login";
          wantedBy = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStart = "${config.programs.steam.package}/bin/steam -silent";
            Restart = "on-failure";
          };
        };
      };
    };
}
