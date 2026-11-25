{ ... }:
{
  flake.nixosModules.desktop-cinnamon =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.nixos.desktop.cinnamon;
      customApplets = pkgs.callPackage ./extensions/_applets.nix { };
    in
    {
      imports = [
        ./partials/_cinnamon.nix
        ./partials/_cinnamon-pinned-apps.nix
        ./partials/_cinnamon-sysmon-applets.nix
        ./partials/_lightdm.nix
      ];

      options.nixos.desktop.cinnamon = {
        enable = lib.mkEnableOption "Cinnamon Desktop Environment with LightDM";
      };

      config = lib.mkIf cfg.enable {
        services.xserver.enable = true;

        environment.systemPackages = with pkgs; [
          customApplets
          libgtop
          lm_sensors
          cinnamon-translations
          nemo
          mousepad
          xclip
        ];

        environment.sessionVariables = {
          GI_TYPELIB_PATH = "${pkgs.libgtop}/lib/girepository-1.0";
        };

        environment.pathsToLink = [
          "/share/themes"
          "/share/icons"
          "/share/cinnamon"
        ];

        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          config.common.default = [ "gtk" ];
        };
      };
    };
}
