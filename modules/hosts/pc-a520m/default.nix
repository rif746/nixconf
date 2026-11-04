{ self, inputs, ... }: {
  flake.nixosConfigurations.pc-a520m = inputs.nixpkgs.lib.nixosSystem {
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
              communication.enable = true;
              jetbrains = {
                enable = true;
                phpstorm.enable = true;
                datagrip.enable = true;
              };
              godot.enable = true;
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
                antigravity.enable = true;
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

        networking.hostName = "pc-a520m";
        system.stateVersion = "26.05";

        nixos = {
          desktop.plasma.enable = true;
          tools = {
            gaming = {
              enable = true;
              steam = {
                enable = true;
              };
            };
            webserver.enable = true;
            virtualisation = {
              kvm.enable = true;
            };
          };
        };
      })
    ];
  };
}
