{ ... }: {
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
    in
    {
      options.features.cli.nvim = {
        enable = lib.mkEnableOption "Enable Neovim";
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          (lib.mkIf hasNixvim {
            programs.nixvim = {
              enable = true;
              defaultEditor = true;
              nixpkgs.config.allowUnfree = true;
              vimAlias = true;
              viAlias = true;
            };
          })

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
