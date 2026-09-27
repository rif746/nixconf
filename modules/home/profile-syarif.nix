{ ... }: {
  flake.homeModules.profile-syarif = { ... }: {
    home.username = "syarif";
    home.homeDirectory = "/home/syarif";
    home.stateVersion = "26.05";

    features.apps.browser.enable = true;
    features.apps.browser.brave.enable = true;
    features.apps.multimedia.enable = true;
    features.apps.lutris.enable = true;
    features.cli.developer.enable = true;
    features.apps.jetbrains = {
      enable = true;
      phpstorm.enable = true;
      datagrip.enable = true;
    };
  };
}
