{ inputs, self, ... }: {
  flake.nixosModules.system-home-manager = { config, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
      extraSpecialArgs = { inherit inputs self; };

      sharedModules = (builtins.attrValues (self.homeModules or { })) ++ [
        inputs.plasma-manager.homeModules.plasma-manager
      ];

      users.${config.system.user.name} = self.homeModules.profile-syarif;
    };
  };
}
