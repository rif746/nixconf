{ inputs, self, ... }: {
  # Automatically registered as self.nixosModules.system-users via import-tree
  flake.nixosModules.system-users =
    {
      user,
      config,
      pkgs,
      options,
      lib,
      ...
    }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      programs.${user.shell}.enable = true;
      users.users.${user.name} = {
        isNormalUser = true;
        description = user.description;
        initialHashedPassword = user.hashedPassword;
        extraGroups = [
          "networkmanager"
          "wheel"
          "audio"
          "video"
          "input"
        ];
        shell = pkgs.${user.shell};
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
        overwriteBackup = true;
        extraSpecialArgs = { inherit inputs self user; };

        sharedModules = (builtins.attrValues (self.homeModules or { })) ++ [
          inputs.plasma-manager.homeModules.plasma-manager
          inputs.nixvim.homeModules.nixvim
          inputs.rif-nixvim.nixvimModules.default
        ];

        users.${user.name} = {
          imports = [ user.profile ];

          home = {
            username = user.name;
            homeDirectory = "/home/${user.name}";
            stateVersion = "26.05";
          };
        };
      };
    };
}
