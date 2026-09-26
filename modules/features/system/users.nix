{ ... }: {
  flake.nixosModules.system-users = { pkgs, ... }: {
    users.users.syarif = {
      isNormalUser = true;
      description = "Syarif Ubaidillah";
      extraGroups = [ "networkmanager" "wheel" ];
    };

    home-manager.users.syarif = {
      home.username = "syarif";
      home.homeDirectory = "/home/syarif";
      home.stateVersion = "26.05";
    };
  };
}
