{ ... }: {
  flake.nixosModules.desktop-plasma = { pkgs, ... }: {
    # Enable X11 and KDE Plasma 6
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    # X11 Keymap
    services.xserver.xkb = {
      layout = "id";
      variant = "";
    };

    # Enable Printing
    services.printing.enable = true;

    # Ensure Konsole and KDE desktop tools are installed
    environment.systemPackages = with pkgs; [
      kdePackages.konsole
      kdePackages.kate
    ];

    # Tell Konsole default profile to use $SHELL (User's configured default shell)
    environment.etc."xdg/konsolerc".text = ''
      [Desktop Entry]
      DefaultProfile=Profile 1.profile

      [Favorite Profiles]
      Favorites=Profile 1.profile
    '';

    environment.etc."xdg/konsole/Profile 1.profile".text = ''
      [General]
      Name=Profile 1
      Parent=FALLBACK/
      Command=/run/current-system/sw/bin/fish
    '';
  };
}
