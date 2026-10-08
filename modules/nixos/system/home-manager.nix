{ inputs, self, ... }: {
  flake.nixosModules.system-home-manager = { ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
      extraSpecialArgs = { inherit inputs self; };

      sharedModules = (builtins.attrValues (self.homeModules or { })) ++ [
        inputs.plasma-manager.homeModules.plasma-manager
      ];

      users.syarif = self.homeModules.profile-syarif;
    };
  };
}
