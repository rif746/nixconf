{ ... }: {
  flake.nixosModules.gaming =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.modules.gaming;
    in
    {
      options.modules.gaming = {
        enable = lib.mkEnableOption "Gaming environment (Steam, GameMode, Lutris, MangoHud)";

        steam.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Steam client and system-level integrations";
        };

        gamemode.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Feral GameMode optimization daemon";
        };

        extraTools.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
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

          fontPackages = with pkgs; [
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-color-emoji
          ];

          extraPackages = with pkgs; [
            protonup-qt
            mangohud
            kdePackages.breeze
          ];
        };

        programs.gamemode.enable = cfg.gamemode.enable;

        systemd.user.services.steam-autostart = {
          description = "Start Steam automatically on login";
          wantedBy = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.steam}/bin/steam -silent";
            Restart = "on-failure";
          };
        };
      };
    };
}
