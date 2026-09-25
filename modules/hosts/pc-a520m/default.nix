{ self, inputs, ... }: {
  flake.nixosConfigurations.a520M = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.a520MConfiguration
    ];
  };
}
