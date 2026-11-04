{ self, inputs, ... }: {
  flake.nixosConfigurations.lowend-pc = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs self;

      user = {
        name = "syarif";
        description = "Syarif Ubaidillah";
        # password generated using `mkpasswd -m sha-512`
        hashedPassword = "$6$UWsUyCZv7tULBZT7$QfJD6lWbXwKQaSH4adtYbnKkT4Wsy0KW6l2ws62rRjm6QZqTtcSs5Uisj7rA3PvUNSZYtvP/t4WESgs.mT43D0";
        shell = "fish";
        profile = {
          features = {
            apps = {
              browser.enable = true;
              jetbrains = {
                enable = true;
                phpstorm.enable = true;
                datagrip.enable = true;
              };
            };
            cli = {
              vcs = {
                enable = true;
                git.enable = true;
              };
              nvim.enable = true;
              llm = {
                enable = true;
                junie.enable = true;
              };
            };
          };
        };
      };
    };
    modules = [
      ./_hardware.nix
      { imports = builtins.attrValues self.nixosModules; }

      ({ ... }: {

        zramSwap = {
          enable = true;
          memoryPercent = 50;
        };

        nix = {
          settings = {
            auto-optimise-store = true;
            cores = 2;
            max-jobs = 2;
          };
        };

        documentation.enable = false;
        documentation.doc.enable = false;
        documentation.man.enable = false;

        boot.kernel.sysctl = {
          "vm.swappiness" = 180;
          "vm.watermark_boost_factor" = 0;
          "vm.watermark_scale_factor" = 125;
        };

        networking.hostName = "lowend-pc";
        system.stateVersion = "26.05";

        nixos = {
          desktop.plasma.enable = true;
          tools = {
            webserver.enable = true;
          };
        };
      })
    ];
  };
}
