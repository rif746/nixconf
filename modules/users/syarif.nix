{ self, ... }: {
  flake.nixosModules.userSyarif = { pkgs, ... }: {
    users.users."syarif" = {
      isNormalUser = true;
      description = "Syarif Ubaidillah";
      extraGroups = [ "networkmanager" "wheel" ];
    };
  };
}
