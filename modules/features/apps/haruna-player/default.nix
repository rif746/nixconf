# modules/features/apps/haruna/default.nix
{ ... }: {
  flake.nixosModules.apps-haruna = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      haruna
      mpv
    ];

    # Konfigurasi dotfiles via Home-Manager
    home-manager.users.syarif = {
      xdg.configFile."haruna/mpv.conf".text = builtins.readFile ./dotfiles/mpv.conf;
      xdg.configFile."haruna/haruna.conf".text = builtins.readFile ./dotfiles/haruna.conf;
    };
  };
}
