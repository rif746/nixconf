{ self, inputs, ... }: {
  flake.nixosModules.nvim = { pkgs, lib, ... }: {
    programs.neovim = {
      enable = true;
    };
  };
} 
 
