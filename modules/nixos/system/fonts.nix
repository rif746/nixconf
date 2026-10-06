{ ... }: {
  flake.nixosModules.system-fonts = { pkgs, ... }: {
    fonts = {
        fontDir.enable = true;
        enableDefaultPackages = true;
        packages = with pkgs; [
            nerd-fonts.fira-code
        ];
    };
  };
}
