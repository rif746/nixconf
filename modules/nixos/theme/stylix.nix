{ inputs, ... }:
{
  flake.nixosModules.system-stylix =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.nixos.theme;
    in
    {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];

      options.nixos.theme = {
        polarity = lib.mkOption {
          type = lib.types.enum [
            "dark"
            "light"
            "either"
          ];
          default = "dark";
          description = "Color scheme polarity (dark, light, or either).";
        };

        image = lib.mkOption {
          type = lib.types.path;
          default = ./wallpaper.png;
          description = "Path to the wallpaper image used by Stylix.";
        };

        scheme = lib.mkOption {
          type = lib.types.str;
          default = "catppuccin-mocha";
          description = "Base16 scheme name from pkgs.base16-schemes (without .yaml).";
        };
      };

      config = {
        stylix = {
          enable = true;
          image = cfg.image;
          autoEnable = true;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.scheme}.yaml";
          polarity = cfg.polarity;

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
    };
}
