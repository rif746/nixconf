{ ... }: {
  flake.nixosModules.system-joystick = { pkgs, user, ... }: {
    boot.kernelModules = [
      "xpad"
      "joydev"
      "uinput"
      "uhid"
    ];

    boot.extraModprobeConfig = ''
      options xpad new_id=0283:0001
    '';

    hardware.uinput.enable = true;

    environment.systemPackages = with pkgs; [
      evtest
      linuxConsoleTools
      jstest-gtk
      game-devices-udev-rules
    ];

    services.udev.extraRules = ''
      # When the 0283:0001 dongle is connected, unbind it from hid-generic and rebind it to xpad
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0283", ATTR{idProduct}=="0001", RUN+="${pkgs.bash}/bin/bash -c 'echo -n %k > /sys/bus/usb/drivers/hid-generic/unbind 2>/dev/null || true'"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0283", ATTR{idProduct}=="0001", RUN+="${pkgs.kmod}/bin/modprobe xpad", RUN+="${pkgs.bash}/bin/bash -c 'echo 0283 0001 > /sys/bus/usb/drivers/xpad/new_id 2>/dev/null || true'"

      # Input permissions for the user
      SUBSYSTEM=="input", ATTRS{idVendor}=="0283", ATTRS{idProduct}=="0001", MODE="0666", GROUP="input"
      KERNEL=="event*", ATTRS{idVendor}=="0283", ATTRS{idProduct}=="0001", MODE="0666", GROUP="input"
      KERNEL=="js*", ATTRS{idVendor}=="0283", ATTRS{idProduct}=="0001", MODE="0666", GROUP="input"
    '';

    users.users.${user.name}.extraGroups = [ "input" ];
  };
}
