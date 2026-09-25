# modules/features/apps/haruna/default.nix
{ ... }: {
  flake.nixosModules.apps-haruna = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      haruna
      mpv
    ];

    system.userActivationScripts.harunaConfig = {
      text = ''
        HARUNA_DIR="${config.users.users.syarif.home}/.config/haruna"
        mkdir -p "$HARUNA_DIR"

        # Membaca isi dari folder dotfiles/
        cat <<'EOF' > "$HARUNA_DIR/mpv.conf"
${builtins.readFile ./dotfiles/mpv.conf}
EOF

        cat <<'EOF' > "$HARUNA_DIR/haruna.conf"
${builtins.readFile ./dotfiles/haruna.conf}
EOF

        chown -R syarif:users "$HARUNA_DIR"
      '';
    };
  };
}
