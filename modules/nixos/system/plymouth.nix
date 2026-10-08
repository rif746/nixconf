{ ... }: {
  flake.nixosModules.system-plymouth = { pkgs, ... }: {
    boot = {
      plymouth = {
        enable = true;

        theme = "breeze";

        themePackages = with pkgs; [
          kdePackages.breeze-plymouth
        ];
      };

      consoleLogLevel = 0;
      initrd.verbose = false;
      initrd.kernelModules = [ "amdgpu" ];
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
    };
  };
}
