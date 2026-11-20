{ ... }: {
  flake.nixosModules.system-libs =
    {
      pkgs,
      config,
      user,
      inputs,
      ...
    }:
    {
      programs = {
        nix-ld = {
          enable = true;
          libraries = with pkgs; [
            # Core C/C++, compression, networking & DB
            stdenv.cc.cc.lib
            zlib
            zstd
            openssl
            curl
            glib
            libxml2
            icu
            sqlite

            # GTK & WebKitGTK (covers Tauri, Wails, and standard GTK3/GTK4 binaries)
            gtk3
            gtk4
            webkitgtk_4_1
            webkitgtk_6_0
            gdk-pixbuf
            cairo
            pango
            harfbuzz
            atk
            libsoup_3

            # Wayland & graphics stack
            wayland
            libxkbcommon
            libGL
            mesa

            # Fuse
            fuse
            fuse3
          ];
        };

        appimage = {
          enable = true;
          binfmt = true;
          package = pkgs.appimage-run;
        };
      };
    };
}
