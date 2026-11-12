{ ... }: {
  flake.homeModules.cli-yazi =
    {
      pkgs,
      ...
    }:

    let
      yazi-pdf-decrypt = pkgs.writeShellApplication {
        name = "yazi-pdf-decrypt";
        runtimeInputs = [ pkgs.qpdf ];
        text = ''
          read -rsp "Password: " ans
          echo ""
          for f in "$@"; do
            echo "Decrypting $f"
            qpdf --decrypt --password="$ans" "$f" -- --replace-input
          done
        '';
      };

      yazi-pdf-cut = pkgs.writeShellApplication {
        name = "yazi-pdf-cut";
        runtimeInputs = [ pkgs.qpdf ];
        text = ''
          read -rp "Save Page (1-z): " ans
          for f in "$@"; do
            echo "Keeping pages $ans in $f"
            qpdf "$f" --pages . "$ans" -- --replace-input
          done
        '';
      };

      yazi-archive-zip = pkgs.writeShellApplication {
        name = "yazi-archive-zip";
        runtimeInputs = [ pkgs.zip ];
        text = ''
          if [ "$#" -eq 1 ]; then
            target="$1"
            name=$(basename "$target" | sed 's/\(.*\)\..*/\1/')
            base=$(basename "$target")
            (cd "$(dirname "$target")" && zip -r "$name.zip" "$base")
          else
            echo "Zip these files?"
            printf '  %s\n' "$@"
            read -rp "Zip name (without .zip): " ans
            [ -z "$ans" ] && exit 0
            items=()
            for f in "$@"; do
              items+=("$(basename "$f")")
            done
            zip -r "$PWD/$ans.zip" "''${items[@]}"
          fi
        '';
      };

      yazi-drag-in = pkgs.writeShellApplication {
        name = "yazi-drag-in";
        runtimeInputs = [ pkgs.dragon-drop ];
        text = ''
          mode="''${1:-copy}"
          files=$(dragon-drop -t -x)
          IFS=$'\n'
          for f in $files; do
            clean=$(echo "$f" | sed -e 's|^file://||' -e 's/%20/ /g')
            if [ "$mode" = "move" ]; then
              mv "$clean" "$PWD/"
            else
              cp -r "$clean" "$PWD/"
            fi
          done
        '';
      };
    in
    {
      home.packages = with pkgs; [
        file
        feh
        fzf
        p7zip
        bat
        chafa
        poppler-utils
        fd
        ripgrep
        jq
        dragon-drop
        udisks2 # Required by mount.yazi (provides udisksctl)
        util-linux # Required by mount.yazi (provides lsblk)
      ];

      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        shellWrapperName = "yy";

        plugins = {
          mount = pkgs.yaziPlugins.mount;
        };

        settings = {
          mgr = {
            ratio = [ 1 4 3 ];
            sort_by = "natural";
            sort_sensitive = false;
            sort_dir_first = true;
            linemode = "size";
            show_hidden = false;
            show_symlink = true;
          };

          preview = {
            wrap = "no";
            tab_size = 2;
            max_width = 1000;
            max_height = 1000;
            image_filter = "triangle";
            image_quality = 75;
          };

          opener = {
            edit = [
              { run = ''$EDITOR "$@"''; block = true; desc = "$EDITOR"; }
            ];
            image = [
              { run = ''feh --scale-down "$@"''; orphan = true; desc = "feh"; }
            ];
            extract = [
              { run = ''ya pub extract --list "$@"''; desc = "Extract here"; }
            ];
            open = [
              { run = ''xdg-open "$1"''; orphan = true; desc = "Open"; }
            ];
          };

          open = {
            rules = [
              { mime = "text/*"; use = [ "edit" ]; }
              { mime = "application/json"; use = [ "edit" ]; }
              { mime = "image/*"; use = [ "image" "open" ]; }
              { mime = "application/{zip,x-tar,x-bzip2,x-7z-compressed,x-rar,xz}"; use = [ "extract" "open" ]; }
              { url = "*"; use = [ "open" ]; }
            ];
          };
        };

        keymap = {
          mgr.prepend_keymap = [
            # Mount manager (mount.yazi)
            { on = [ "M" ]; run = "plugin mount"; desc = "Open mount manager"; }

            # Quick directory jumps
            { on = [ "d" "d" ]; run = "cd /mnt/Data"; desc = "Go to /mnt/Data"; }
            { on = [ "d" "/" ]; run = "cd /"; desc = "Go to /"; }
            { on = [ "d" "h" ]; run = "cd ~"; desc = "Go to Home"; }
            { on = [ "d" "s" ]; run = "cd /srv/http"; desc = "Go to /srv/http"; }
            { on = [ "d" "m" ]; run = "cd /run/media"; desc = "Go to /run/media"; }

            # Native Yazi built-in commands
            { on = [ "+" "d" ]; run = "create --dir"; desc = "Create directory"; }
            { on = [ "+" "f" ]; run = "create"; desc = "Create file"; }
            { on = [ "<Delete>" ]; run = "remove"; desc = "Trash selected files"; }
            { on = [ "<S-Delete>" ]; run = "remove --permanently"; desc = "Permanently delete"; }
            { on = [ "g" ]; run = "hidden toggle"; desc = "Toggle hidden files"; }
            { on = [ "c" "c" ]; run = [ "yank" "paste" ]; desc = "Copy & paste in-place"; }
            { on = [ "c" "m" ]; run = [ "yank --cut" "paste" ]; desc = "Cut & paste"; }
            { on = [ "/" ]; run = "plugin fzf"; desc = "Jump with fzf"; }
            { on = [ "a" "u" ]; run = "plugin extract"; desc = "Extract archive"; }
            { on = [ "r" ]; run = "rename --cursor=before_ext"; desc = "Rename / Bulk rename in $EDITOR"; }
            { on = [ "s" "t" "u" ]; run = "rename --cursor=before_ext"; desc = "Bulk rename in $EDITOR"; }
            { on = [ "b" ]; run = ''shell '$EDITOR "$PWD"' --block''; desc = "Open current dir in Neovim"; }

            # External helper scripts
            { on = [ "a" "z" ]; run = ''shell '${yazi-archive-zip}/bin/yazi-archive-zip "$@"' --block''; desc = "Zip selected"; }
            { on = [ "x" "x" ]; run = ''shell 'dragon-drop -a -x "$@"' --orphan''; desc = "Drag and drop out"; }
            { on = [ "x" "c" ]; run = ''shell '${yazi-drag-in}/bin/yazi-drag-in copy' --block''; desc = "Drag and drop copy in"; }
            { on = [ "x" "m" ]; run = ''shell '${yazi-drag-in}/bin/yazi-drag-in move' --block''; desc = "Drag and drop move in"; }
            { on = [ "p" "d" ]; run = ''shell '${yazi-pdf-decrypt}/bin/yazi-pdf-decrypt "$@"' --block''; desc = "Decrypt PDF"; }
            { on = [ "p" "c" ]; run = ''shell '${yazi-pdf-cut}/bin/yazi-pdf-cut "$@"' --block''; desc = "Cut PDF pages"; }

            # Wallpaper & Lockscreen
            {
              on = [ "w" "p" ];
              run = ''shell 'cp "$0" ~/.config/.wallpaper.png && feh --bg-fill "$0"' --orphan'';
              desc = "Set as wallpaper";
            }
            {
              on = [ "w" "l" ];
              run = ''shell 'betterlockscreen -u "$0" && betterlockscreen -l dim' --orphan'';
              desc = "Set as lockscreen";
            }
          ];
        };
      };
    };
}
