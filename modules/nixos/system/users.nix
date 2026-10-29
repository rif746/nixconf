{ ... }: {
  # Terdaftar otomatis ke self.nixosModules.system-users via import-tree
  flake.nixosModules.system-users = { config, pkgs, options, lib, ... }: let
    cfg = config.system.user;
  in {
    options.system.user = {
      name = lib.mkOption{
        type = lib.types.str;
        default = "user";
        description = "Username";
      };
      description = lib.mkOption{
        type = lib.types.str;
        default = "User";
        description = "User Description.";
      };
    };

    config = {
      programs.fish.enable = true;
      users.users.${cfg.name} = {
        isNormalUser = true;
        description = cfg.description;
        extraGroups = [
          "networkmanager"
          "wheel"
          "audio"
          "video"
          "input"
        ];
        shell = pkgs.fish;
      };
    };
  };
}
