{ ... }: {
  flake.nixosModules.system-fonts = { pkgs, ... }: {
    fonts = {
        enable = true;
        fontDir.enable = true;
        enableDefaultPackages = true;
        packages = with pkgs; [
            nerd-fonts.fira-code
        ];
    };
  };
}
