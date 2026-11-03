{ ... }: {
  flake.nixosModules.system-core =
    {
      pkgs,
      config,
      user,
      ...
    }:
    {
      # System Packages & Nix Settings
      nixpkgs.config.allowUnfree = true;

      # Locale & Timezone
      time.timeZone = "Asia/Jakarta";
      i18n.defaultLocale = "id_ID.UTF-8";

      networking = {
        networkmanager.enable = true;
        nftables.enable = true;
        firewall.enable = true;
      };

      hardware = {
        bluetooth.enable = true;
        graphics.enable = true;
      };

      security = {
        polkit.enable = true;
        rtkit.enable = true;
        sudo.enable = true;
      };

      # Ensure core tools are installed
      environment.systemPackages = with pkgs; [
        nixd
        nixfmt
        p7zip
        p7zip-rar
        zip
        unzip
        rar
        usbutils
        tree
        pciutils
        coreutils
        haruna
        mpv
        gtop
      ];

      # Nix settings, auto cleanup and enable flakes
      nix = {
        settings = {
          auto-optimise-store = true;
          allowed-users = [ user.name ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 3d";
        };
      };
    };
}
