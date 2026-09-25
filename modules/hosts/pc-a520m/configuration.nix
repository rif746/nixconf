{ self, ... }: {

  flake.nixosModules.a520MConfiguration = { pkgs, ... }: {
    imports = [
      # Hardware
      self.nixosModules.a520MHardware

      # Modular Features
      self.nixosModules.desktopPlasma
      self.nixosModules.audio
      self.nixosModules.userSyarif
      self.nixosModules.fish

      # Standalone program modules
      self.nixosModules.git
      self.nixosModules.firefox
      self.nixosModules.nvim
      self.nixosModules.haruna
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

    # System Packages & Nix Settings
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    system.stateVersion = "26.05";
  };

}

