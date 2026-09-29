{ ... }: {
  flake.nixosModules.system-bootloader = { pkgs, ... }: {
    # Bootloader Setup
    boot.loader = {
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = true;
        grub = {
            enable = true;
            efiSupport = true;
            device = "nodev";
            theme = "${pkgs.kdePackages.breeze-grub}/grub/themes/breeze";
        };
    };
  };
}
