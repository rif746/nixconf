{ ... }: {
  flake.nixosModules.system-lowspec =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.nixos.lowspec;
    in
    {
      options.nixos.lowspec.enable = lib.mkEnableOption "Enable Lowspec Configuration";

      config = lib.mkIf cfg.enable {
        zramSwap = {
          enable = true;
          memoryPercent = 50;
          algorithm = "zstd";
        };

        services.earlyoom = {
          enable = true;
          enableNotifications = true;
          freeMemThreshold = 15;
          freeSwapThreshold = 10;
        };

        powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
        boot.kernel.sysctl = {
          "vm.swappiness" = 180;
          "vm.watermark_boost_factor" = 0;
          "vm.watermark_scale_factor" = 125;
          "vm.page-cluster" = 0;
          "vm.vfs_cache_pressure" = 50;
          "net.core.somaxconn" = 1024;
          "net.ipv4.tcp_fastopen" = 3;
        };

        services.ananicy = {
          enable = true;
          package = pkgs.ananicy-cpp;
          rulesProvider = pkgs.ananicy-rules-cachyos;
        };

        services.udev.extraRules = ''
          ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
          ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="kyber"
        '';

        nix = {
          settings = {
            auto-optimise-store = true;
            cores = 2;
            max-jobs = 2;
          };
        };

        documentation = {
          enable = false;
          doc.enable = false;
          man.enable = false;
          info.enable = false;
        };

        services.journald.settings.Journal = {
          SystemMaxUse = "100M";
          Storage = "persistent";
          Compress = "yes";
        };
      };
    };
}
