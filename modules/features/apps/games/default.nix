{ ... }: {
  flake.nixosModules.gaming = { config, lib, pkgs, ... }: let
    cfg = config.modules.gaming;
  in {
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
      # 1. Integrasi Steam System-level
      programs.steam = lib.mkIf cfg.steam.enable {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        protontricks.enable = true;
        gamescopeSession.enable = true;
      };

      # 2. Daemon GameMode Optimization
      programs.gamemode.enable = cfg.gamemode.enable;

      # 3. Game Launchers & Monitoring Tools
      environment.systemPackages = lib.optionals cfg.extraTools.enable (with pkgs; [
        protonup-qt
        mangohud
      ]);
    };
  };
}
