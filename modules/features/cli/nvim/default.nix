{ ... }: {
  flake.nixosModules.cli-nvim = { pkgs, lib, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      withNodeJs = true;
      withPython3 = true;
    };
  };
} 
 
