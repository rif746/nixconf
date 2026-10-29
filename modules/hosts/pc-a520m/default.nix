{ self, inputs, ... }: {
  flake.nixosConfigurations.a520M = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      { imports = builtins.attrValues self.nixosModules; }

      ({ ... }: {
        system.user = {
          name = "syarif";
          description = "Syarif Ubaidillah";
        };

        modules.gaming.enable = true;
        modules.devkit.webserver.enable = true;
        modules.desktop.plasma.enable = true;
        modules.virtualisation = {
          kvm.enable = true;
        };

        networking.hostName = "pc-a520m";
        system.stateVersion = "26.05";
      })
    ];
  };
}
