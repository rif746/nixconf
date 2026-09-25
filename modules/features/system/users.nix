{ ... }: {
  flake.nixosModules.system-users = { pkgs, ... }: {
    users.users.syarif = {
      isNormalUser = true;
      description = "Syarif Ubaidillah";
      extraGroups = [ "networkmanager" "wheel" ];
    };
  };
}
