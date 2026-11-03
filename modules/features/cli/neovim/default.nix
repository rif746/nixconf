{ ... }: {
  flake.homeModules.shell =
    { config, lib, ... }:
    let
      cfg = config.features.cli.nvim;
    in
    {
      options.features.cli.nvim.enable = lib.mkEnableOption "Enable Neovim";
      config = lib.mkIf cfg.enable {
        programs.neovim = {
          enable = true;
          defaultEditor = true;
          vimAlias = true;
          viAlias = true;
          withNodeJs = true;
          withPython3 = true;
          waylandSupport = true;
        };
      };
    };
}
