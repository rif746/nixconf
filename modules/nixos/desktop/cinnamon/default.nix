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
    in
    {
      imports = [
        ./partials/_cinnamon.nix
        ./partials/_cinnamon-pinned-apps.nix
        ./partials/_lightdm.nix
      ];

      options.nixos.desktop.cinnamon = {
        enable = lib.mkEnableOption "Cinnamon Desktop Environment with LightDM and Picom";
      };

      config = lib.mkIf cfg.enable {
        services.xserver.enable = true;
        stylix.targets.gtk.enable = false;

        environment.systemPackages = with pkgs; [
          cinnamon-translations
          gnome-terminal
          nemo
          mousepad
          xclip
        ];

        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          config.common.default = [ "gtk" ];
        };
      };
    };
}
