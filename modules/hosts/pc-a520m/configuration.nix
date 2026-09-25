{ self, ... }: {

  flake.nixosModules.a520MConfiguration = { pkgs, ... }: {
    imports = [
      # Hardware
      self.nixosModules.a520MHardware

      # System
      self.nixosModules.desktop-plasma
      self.nixosModules.system-audio
      self.nixosModules.system-users

      # Apps
      self.nixosModules.cli-fish
      self.nixosModules.cli-git
      self.nixosModules.cli-nvim
      self.nixosModules.apps-firefox
      self.nixosModules.apps-haruna
    ];

    # Bootloader Setup
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub.enable = false;

    # Kernel & Host Settings
    boot.kernelPackages = pkgs.linuxPackages_latest;
    networking.hostName = "pc-a520m";
    networking.networkmanager.enable = true;

    # Locale & Timezone
    time.timeZone = "Asia/Jakarta";
    i18n.defaultLocale = "id_ID.UTF-8";

    # Ensure Konsole and KDE desktop tools are installed
    environment.systemPackages = with pkgs; [
      nil
    ];

    # System Packages & Nix Settings
    nixpkgs.config.allowUnfree = true;

    # Nix settings, auto cleanup and enable flakes
    nix = {
        settings.auto-optimise-store = true;
        settings.allowed-users = [ "syarif" ];
        settings.experimental-features = [ "nix-command" "flakes" ];
        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
        };
    };


    system.stateVersion = "26.05";
  };

}

