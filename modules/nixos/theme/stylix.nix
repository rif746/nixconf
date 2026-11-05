{ ... }: {
  flake.nixosModules.system-stylix = { pkgs, ... }: {
    stylix = {
      enable = true;
      image = ./wallpaper.png;
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      polarity = "dark";

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      fonts = {
        serif = {
          package = pkgs.lora;
          name = "Lora";
        };
        sansSerif = {
          package = pkgs.inter;
          name = "Inter";
        };
        monospace = {
          package = pkgs.nerd-fonts.iosevka;
          name = "Iosevka Nerd Font";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };

        sizes = {
          terminal = 11;
          desktop = 10;
        };
      };
    };
  };
}
