{ ... }:
{
  flake.homeModules.shell =
    {
      config,
      lib,
      options,
      pkgs,
      ...
    }:
    let
      cfg = config.features.cli.nvim;
      hasNixvim = options.programs ? nixvim;
      hasStylixModule = options ? stylix;
      stylixColors = config.lib.stylix.colors.withHashtag or { };
      hasStylixColors = hasStylixModule && (config.stylix.enable or false) && (stylixColors ? base00);
    in
    {
      options.features.cli.nvim = {
        enable = lib.mkEnableOption "Enable Neovim";
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          (lib.mkIf hasNixvim (
            lib.mkMerge [
              (lib.optionalAttrs hasStylixModule {
                stylix.targets.neovim.enable = false;
                stylix.targets.nixvim.enable = false;
              })

              {
                programs.nixvim = {
                  enable = true;
                  defaultEditor = true;
                  nixpkgs.config.allowUnfree = true;
                  vimAlias = true;
                  viAlias = true;

                  myNixvim.colors = lib.mkIf hasStylixColors {
                    base00 = stylixColors.base00;
                    base01 = stylixColors.base01;
                    base02 = stylixColors.base02;
                    base03 = stylixColors.base03;
                    base04 = stylixColors.base04;
                    base05 = stylixColors.base05;
                    base06 = stylixColors.base06;
                    base07 = stylixColors.base07;
                    base08 = stylixColors.base08;
                    base09 = stylixColors.base09;
                    base0A = stylixColors.base0A;
                    base0B = stylixColors.base0B;
                    base0C = stylixColors.base0C;
                    base0D = stylixColors.base0D;
                    base0E = stylixColors.base0E;
                    base0F = stylixColors.base0F;
                  };
                };
              }
            ]
          ))

          (lib.mkIf (!hasNixvim) {
            programs.neovim = {
              enable = true;
              defaultEditor = true;
              vimAlias = true;
              viAlias = true;
              withNodeJs = true;
              withPython3 = true;
              withRuby = false;
            };

            home.packages = with pkgs; [
              tree-sitter
              ripgrep
              fd
            ];
          })
        ]
      );
    };
}
