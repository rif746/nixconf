{ ... }: {
  flake.homeModules.profile-syarif = { pkgs, ... }: {
    home.username = "syarif";
    home.homeDirectory = "/home/syarif";
    home.stateVersion = "26.05";

    features.apps.browser.enable = true;
    features.desktop.plasma.enable = true;
    features.apps.multimedia.enable = true;
    features.apps.lutris.enable = true;
    features.apps.communication.enable = true;
    features.apps.jetbrains = {
      enable = true;
      phpstorm.enable = true;
      datagrip.enable = true;
    };
    features.apps.godot.enable = true;
    features.cli.developer.enable = true;
    features.cli.llm.enable = true;
    features.cli.llm.junie.enable = true;
    features.cli.llm.antigravity.enable = true;
  };
}
