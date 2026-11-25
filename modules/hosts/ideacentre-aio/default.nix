{ self, inputs, ... }: {
  flake.nixosConfigurations.ideacentre-aio = inputs.nixpkgs.lib.nixosSystem {
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
              kitty.enable = true;
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
        networking.hostName = "ideacentre-aio";
        system.stateVersion = "26.05";

        nixos = {
          lowspec.enable = true;
          desktop.cinnamon.enable = true;
          tools = {
            devkit.adb.enable = true;
            webserver.enable = true;
            twindesk.enable = true;
          };
        };
      })
    ];
  };
}
