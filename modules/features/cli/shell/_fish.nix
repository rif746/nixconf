{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -g fish_greeting ""
    '';

    shellAbbrs = {
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      gpl = "git pull";
    };

    plugins = [
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
      {
        name = "colored-man-pages";
        src = pkgs.fishPlugins.colored-man-pages.src;
      }
    ];
  };

  programs.starship.enableFishIntegration = true;
}
