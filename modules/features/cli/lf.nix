{ ... }: {
  flake.homeModules.cli-lf =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    let
      # Previewer Script untuk lf
      lf-preview = pkgs.writeShellScript "lf-preview" ''
        file="$1"
        width="$2"
        height="$3"
        horizontal_position="$4"
        vertical_position="$5"

        case "$(${pkgs.file}/bin/file --mime-type -bL "$file")" in
          text/* | application/json | application/x-subrip)
            ${pkgs.bat}/bin/bat --color=always --style=plain "$file" || ${pkgs.coreutils}/bin/cat "$file"
            ;;
          image/*)
            # Integrasi preview gambar (cth: chafa / pistol)
            ${pkgs.chafa}/bin/chafa --size="$\{width}x$\{height}" "$file"
            ;;
          application/pdf)
            ${pkgs.poppler-utils}/bin/pdftotext "$file" -
            ;;
          *)
            ${pkgs.file}/bin/file -b "$file"
            ;;
        esac
      '';

      # Cleaner Script untuk lf
      lf-cleaner = pkgs.writeShellScript "lf-cleaner" ''
        # Tempatkan perintah pembersihan preview (misal hapus cache gambar) jika diperlukan
        exit 0
      '';
    in
    {
      # Pastikan paket pendukung yang digunakan dalam skrip cmd tersedia
      home.packages = with pkgs; [
        file
        feh
        fzf
        qpdf
        unzip
        unrar
        p7zip
        zip
        dragon-drop
        progress
      ];

      programs.lf = {
        enable = true;

        # Opsi dasar lf
        settings = {
          drawbox = true;
          icons = true;
          dirfirst = true;
          previewer = "${lf-preview}";
          cleaner = "${lf-cleaner}";
        };

        # Custom Commands
        commands = {
          open = ''
            ''${{
              case $(file --mime-type "$f" -bL) in
                  text/* | application/json) $EDITOR "$f" ;;
                  image/*) feh --scale-down "$f" & disown ;;
                  *) xdg-open "$f" &> /dev/null & disown ;;
              esac
            }}
          '';

          mkdir = ''
            ''${{
              clear
              echo -n "Directory Name : "
              read ans
              mkdir "$ans"
              clear
            }}
          '';

          mkfile = ''
            ''${{
              clear
              echo -n "File Name : "
              read ans
              $EDITOR "$ans"
              clear
            }}
          '';

          fzf = ''
            ''${{
              clear
              res=$(fzf --reverse --header='Jump To Location')
              if [ -f "$res" ]; then
                  cmd="select"
              else
                  cmd="cd"
              fi
              lf -remote "send $id $cmd \"$res\""
              clear
            }}
          '';

          pdf_decrypt = ''
            ''${{
              clear
              echo -n "Password: "
              read ans
              if [ -z "$fs" ]; then
                  echo "Decrypting $fs"
                  qpdf --decrypt --password="$ans" "$fs" -- --replace-input
              else
                  IFS=$'\n'
                  for f in $fs; do
                      echo "Decrypting $f"
                      qpdf --decrypt --password="$ans" "$f" -- --replace-input
                  done
              fi
              lf -remote "send unselect"
              lf -remote "send reload"
              clear
            }}
          '';

          pdf_cut_page = ''
            ''${{
              clear
              echo -n "Save Page (1-z): "
              read ans
              IFS=$'\n'
              for f in $fs; do
                  echo "Removing page in $f"
                  qpdf "$f" --pages . $ans -- --replace-input
              done
              lf -remote "send unselect"
              lf -remote "send reload"
              clear
            }}
          '';

          remove = ''
            ''${{
              clear
              if [ -z "$fs" ]; then
                  echo "$f"
                  echo -n "Delete ? [y/n] "
                  read ans
                  [ "$ans" = "y" ] && rm -rf "$f"
              else
                  printf "$fs\n"
                  echo -n "Delete ? [y/n] "
                  read ans
                  if [ "$ans" = "y" ]; then
                      IFS=$'\n'
                      for f in $fs; do
                          echo "Removing $f"
                          rm -rf "$f"
                      done
                  else
                      echo "Cancelled"
                  fi
              fi
              clear
              lf -remote "send unselect"
              lf -remote "send reload"
              clear
            }}
          '';

          copy_paste = ''
            ''${{
              clear
              if [ -z $fs ]; then
                  echo "No File or Directory Selected"
                  sleep 1;
              else
                  IFS=$'\n'
                  for f in $fs; do
                      cp -r "$f" "$(pwd)/" &
                      progress -m
                  done
                  lf -remote "send unselect"
                  lf -remote "send reload"
              fi
              clear
            }}
          '';

          move_paste = ''
            ''${{
              clear
              if [ -z $fs ]; then
                  echo "No File or Directory Selected"
                  sleep 1;
              else
                  IFS=$'\n'
                  for f in $fs; do
                      mv "$f" "$(pwd)/" &
                      progress -m
                  done
                  lf -remote "send unselect"
                  lf -remote "send reload"
              fi
              clear
            }}
          '';

          dragandrop = ''
            ''${{
              clear
              IFS=$'\n'
              dragon-drop -a -x $fx
              clear
              lf -remote "send unselect"
              lf -remote "send reload"
            }}
          '';

          dragandropcopy = ''
            ''${{
              clear
              file=$(dragon-drop -t -x)
              IFS=$'\n'
              echo $file
              for f in $file; do
                file=$(echo "$f" | sed 's/file:\/\///' | sed -e 's/%20/ /g')
                cp "$file" "$(pwd)/" &
                progress -m
              done
              lf -remote "send unselect"
              lf -remote "send reload"
              clear
            }}
          '';

          dragandropmove = ''
            ''${{
              clear
              files=$(dragon-drop -t -x)
              IFS=$'\n'
              for f in $files; do
                file=$(echo "$f" | sed 's/file:\/\///' | sed -e 's/%20/ /g')
                mv "$file" "$(pwd)/" &
                progress -m
              done
              clear
              lf -remote "send unselect"
              lf -remote "send reload"
            }}
          '';

          space2underscore = ''
            ''${{
              IFS=$'\n'
              for i in $fs;
              do
                  FILE=$(basename "$i")
                  mv "$i" ''${FILE// /_};
              done
              lf -remote "send unselect"
              lf -remote "send reload"
              clear
            }}
          '';

          unarchive = ''
            ''${{
              clear
              if [ -z "$fs" ]; then
                FOLDER=$(basename "$f" | sed 's/\(.*\)\..*/\1/')
                case "$f" in
                  *.zip)
                      unzip "$f" -d "$(pwd)/$FOLDER" ;;
                  *.rar)
                      DIRNOW=$(pwd)
                      DIR=$(unrar lb "$f")
                      IFS=$'\n'
                      for i in $DIR; do
                        if [[ ! "''${i%/*}" = "$FOLDER" ]]; then
                          mkdir "$(pwd)/$FOLDER"
                          cd "$(pwd)/$FOLDER"
                          break
                        fi
                      done
                      unrar x "$f"
                      cd $DIRNOW
                      ;;
                  *.tar.*)
                      mkdir "$(pwd)/''${FOLDER%.*}"
                      tar -xf "$f" --directory="$(pwd)/''${FOLDER%.*}" --verbose
                      ;;
                  *.7z)
                      mkdir "$(pwd)/''${FOLDER%.*}"
                      7z x "$f"
                      ;;
                esac
              else
                echo "Do you want to extract "
                printf "$fs\n"
                echo -n "to $(pwd) ? [y/n] "
                read ans
                if [[ "$ans" = "y" ]]; then
                    IFS=$'\n'
                    for f in $fs; do
                      clear
                      FOLDER=$(basename "$f" | sed 's/\(.*\)\..*/\1/')
                      case "$f" in
                          *.zip)
                              unzip "$f" -d "$(pwd)/$FOLDER" ;;
                          *.rar)
                              DIRNOW=$(pwd)
                              DIR=$(unrar lb "$f")
                              IFS=$'\n'
                              for i in $DIR; do
                                if [[ ! "''${i%/*}" = "$FOLDER" ]]; then
                                  mkdir "$(pwd)/$FOLDER"
                                  cd "$(pwd)/$FOLDER"
                                  break
                                fi
                              done
                              unrar x "$f"
                              cd $DIRNOW
                              ;;
                          *.tar.gz)
                              mkdir "$(pwd)/''${FOLDER%.*}"
                              tar -xf "$f" --directory="$(pwd)/''${FOLDER%.*}" --verbose
                              ;;
                          *.7z)
                              7z x "$f"
                              ;;
                      esac
                    done
                fi
              fi
              lf -remote "send unselect"
              lf -remote "send reload"
              clear
            }}
          '';

          archive_zip = ''
            ''${{
              clear
              if [ -z "$fs" ]; then
                  files=$(basename "$f" | sed 's/\(.*\)\..*/\1/')
                  file=$(basename "$f")
                  if [ -d "$f" ]; then
                      ex="/*"
                  fi
                  zip -r "$(pwd)/$files.zip" "$file"$ex
              else
                  echo "zip this files ?"
                  printf "$fs\n"
                  echo "=============================="
                  echo -n " [y/n] "
                  read ans
                  if [[ "$ans" = "y" ]]; then
                      echo -n "zip name : "
                      read ans
                      file=()
                      for f in $fs; do
                          if [ -d "$f" ]; then
                              file+="$(basename "$f")/* "
                          else
                              file+="$(basename "$f") "
                          fi
                      done
                      zip "$(pwd)/$ans" $file
                  fi
              fi
              lf -remote "send unselect"
              clear
            }}
          '';

          setwp = ''
            ''${{
              clear
              echo "Setting up Wallpaper"
              cp "$f" ~/.config/.wallpaper.png
              feh --bg-fill "$f"
              clear
            }}
          '';

          setLockScreen = ''
            ''${{
              clear
              betterlockscreen -u "$f"
              betterlockscreen -l dim
              clear
            }}
          '';
        };

        # Keybindings Kustom
        keybindings = {
          "<enter>" = "open";
          "+d" = "mkdir";
          "+f" = "mkfile";
          "<delete>" = "remove";
          "au" = "unarchive";
          "az" = "archive_zip";
          "cc" = "copy_paste";
          "cm" = "move_paste";
          "dd" = "cd /mnt/Data";
          "d/" = "cd /";
          "dh" = "cd ~";
          "ds" = "cd /srv/http";
          "dm" = "cd /run/media";
          "g" = "set hidden!";
          "/" = "fzf";
          "b" = "$nvim $(pwd)";
          "xx" = "dragandrop";
          "xc" = "dragandropcopy";
          "xm" = "dragandropmove";
          "wp" = "setwp";
          "wl" = "setLockScreen";
          "stu" = "space2underscore";
          "pd" = "pdf_decrypt";
          "pc" = "pdf_cut_page";
        };
      };
    };
}
