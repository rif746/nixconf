{ self, inputs, ... }: {
  flake.nixosConfigurations.a520M = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      { imports = builtins.attrValues self.nixosModules; }

      ({ ... }: {
        modules.gaming.enable = true;
        modules.devkit.webserver.enable = true;

        networking.hostName = "pc-a520m";
        system.stateVersion = "26.05";
      })
    ];
  };
}
