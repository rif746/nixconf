{ self, ... }: {
  flake.nixosModules.haruna = { pkgs, config, ... }: {
    environment.systemPackages = with pkgs; [
      haruna
      mpv
    ];

    system.userActivationScripts.harunaConfig = {
      text = ''
        HARUNA_DIR="${config.users.users.syarif.home}/.config/haruna"
        mkdir -p "$HARUNA_DIR"

        cat <<EOF > "$HARUNA_DIR/mpv.conf"
# Hardware Acceleration
hwdec=auto-safe
vo=gpu-next
gpu-api=auto

# Presets Kualitas Gambar
profile=high-quality
scale=eawa_lanczos
cscale=eawa_lanczos

# Perbaikan Kualitas & Pemutaran
dither-depth=auto
deband=yes
video-sync=display-resample
interpolation=yes
tscale=oversample

# Audio & Subtitle Defaults
alang=ind,id,eng,en
slang=ind,id,eng,en
sub-auto=fuzzy
sub-font="Sans Serif"
sub-font-size=42
sub-bold=yes
EOF

        cat <<EOF > "$HARUNA_DIR/haruna.conf"
[General]
useBreezeIconTheme=true
useSystemTitleBar=false
hideHeaderBarOnMouseHide=true
rememberWindowSize=true

[Video]
pauseOnMinimize=true

[Subtitles]
subFont=Sans Serif
subFontSize=20
subColor=#FFFF00
EOF

        chown -R syarif:users "$HARUNA_DIR"
      '';
    };
  };
}
