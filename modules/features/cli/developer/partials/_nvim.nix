{ config, lib, ... }:
let
  cfg = config.features.cli.developer;
in
{
    config = lib.mkIf (cfg.enable && cfg.nvim.enable) {
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
}
