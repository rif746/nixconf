{ ... }: {
  flake.nixosModules.cli-nvim = { pkgs, lib, ... }: {
    programs.neovim = {
      enable = true;
    };
  };
} 
 
