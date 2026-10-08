{ ... }: {
  # Terdaftar otomatis ke self.nixosModules.system-users via import-tree
  flake.nixosModules.system-users = { pkgs, ... }: {
    programs.fish.enable = true;
    users.users.syarif = {
      isNormalUser = true;
      description = "Syarif";
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
}
