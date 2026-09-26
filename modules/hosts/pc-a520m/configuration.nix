{ self, inputs, ... }: {

  flake.nixosModules.a520MConfiguration = { pkgs, ... }: {
    imports = [
      # Home Manager
      inputs.home-manager.nixosModules.home-manager

      # Hardware
      self.nixosModules.a520MHardware

      # System
      self.nixosModules.desktop-plasma
      self.nixosModules.system-audio
      self.nixosModules.system-users
      self.nixosModules.system-joystick
      self.nixosModules.system-plymouth

      # Apps
      self.nixosModules.cli-fish
      self.nixosModules.cli-git
      self.nixosModules.cli-nvim
      self.nixosModules.apps-firefox
      self.nixosModules.apps-haruna
    ];

    # Bootloader Setup
    boot.loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;

        consoleMode = "max";

        editor = false;
      };
    };


    # Kernel & Host Settings
    boot.kernelPackages = pkgs.linuxPackages_latest;
    networking.hostName = "pc-a520m";
    networking.networkmanager.enable = true;

    # Locale & Timezone
    time.timeZone = "Asia/Jakarta";
    i18n.defaultLocale = "id_ID.UTF-8";

    # Ensure core tools are installed
    environment.systemPackages = with pkgs; [
      nil
      usbutils
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

    # Home-Manager global settings
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs self; };
      backupFileExtension = "bak";

      # Masukkan Plasma-Manager ke Home-Manager user syarif
      users.syarif = {
        imports = [
          inputs.plasma-manager.homeManagerModules.plasma-manager
        ];
      };
    };


    system.stateVersion = "26.05";
  };

}

