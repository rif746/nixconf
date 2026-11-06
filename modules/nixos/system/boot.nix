{ ... }: {
  flake.nixosModules.system-boot = { pkgs, ... }: {
    boot = {
      loader = {
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = true;
        efi.efiSysMountPoint = "/boot";
        grub = {
          enable = true;
          efiSupport = true;
          device = "nodev";
          #           theme = "${pkgs.kdePackages.breeze-grub}/grub/themes/breeze";
        };
      };

      kernelParams = [
        "quiet"
        "splash"

        "fbcon=nodefer"
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
        "vt.global_cursor_default=0"
      ];

      kernel.sysctl."vm.overcommit_memory" = 1;
      kernelPackages = pkgs.linuxPackages_latest;
      tmp.cleanOnBoot = true;
      consoleLogLevel = 0;
      initrd.verbose = false;
      initrd.kernelModules = [ "amdgpu" ];

      plymouth = {
        enable = true;
        #         theme = "breeze";
        #         themePackages = with pkgs; [
        #           kdePackages.breeze-plymouth
        #         ];
      };
    };
  };
}
