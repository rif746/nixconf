{ ... }: {
  flake.nixosModules.system-core = { pkgs, ... }: {
    # System Packages & Nix Settings
    nixpkgs.config.allowUnfree = true;

    # Locale & Timezone
    time.timeZone = "Asia/Jakarta";
    i18n.defaultLocale = "id_ID.UTF-8";

    # Kernel Settings
    boot.kernel.sysctl."vm.overcommit_memory" = 1;
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.tmp.cleanOnBoot = true;
    networking = {
      networkmanager.enable = true;
      nftables.enable = true;
      firewall.enable = true;
    };

    security.polkit.enable = true;
    security.rtkit.enable = true;
    security.sudo.enable = true;

    # Ensure core tools are installed
    environment.systemPackages = with pkgs; [
      nil
      zip
      unzip
      rar
      usbutils
      tree
      pciutils
      coreutils
    ];

    # Nix settings, auto cleanup and enable flakes
    nix = {
      settings.auto-optimise-store = true;
      settings.allowed-users = [ "syarif" ];
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
  };
}
