{ ... }: {
  flake.homeModules.shell =
    { pkgs, user, ... }:
    let
      dragonDropHandler = pkgs.writeShellScriptBin "dragon-drop-receive" ''
        set -euo pipefail

        mode="copy"
        dest="$PWD"

        for arg in "$@"; do
          case "$arg" in
            -m|--move|move)
              mode="move"
              ;;
            *)
              if [ -d "$arg" ]; then
                dest="$arg"
              else
                echo "Error: Direktori '$arg' tidak ditemukan." >&2
                exit 1
              fi
              ;;
          esac
        done

        # Gunakan -t -k (keep) agar bisa drop berkali-kali; tutup jendela / Esc jika selesai
        ${pkgs.dragon-drop}/bin/dragon-drop -t -k | while IFS= read -r uri; do
          # Hapus trailing \r dari format text/uri-list
          uri="''${uri%$'\r'}"
          [ -z "$uri" ] && continue

          # Decode file:// URI secara akurat menggunakan Python bawaan
          clean_path=$(${pkgs.python3}/bin/python3 -c '
            import sys, urllib.parse
            u = urllib.parse.urlparse(sys.argv[1])
            print(urllib.parse.unquote(u.path))
            ' "$uri")

          if [ ! -e "$clean_path" ]; then
            echo "Lewati (tidak ditemukan): $clean_path" >&2
            continue
          fi

          if [ "$mode" = "move" ]; then
            mv -iv "$clean_path" "$dest/"
          else
            cp -ivr "$clean_path" "$dest/"
          fi
        done
      '';
    in
    {
      imports = [
        (./. + "/_${user.shell}.nix")
      ];

      home = {
        packages = [
          pkgs.devenv
          dragonDropHandler
        ];
        shellAliases = {
          rebuild = "sudo nixos-rebuild switch --flake";
          retest = "sudo nixos-rebuild test --flake";
          nix-clear = "sudo nix-collect-garbage -d";
          c = "clear";
          g = "git";
          drag = "${pkgs.dragon-drop}/bin/dragon-drop -a -x";
          drop = "dragon-drop-receive";
          dropm = "dragon-drop-receive --move";
        };
      };

      programs.starship = {
        enable = true;

        settings = {
          "$schema" = "https://starship.rs/config-schema.json";

          format = "$hostname$directory$sudo$cmd_duration($git_branch$git_commit$git_state$git_metrics$git_status)([via ](bright-black)$nix_shell\${custom.flake}$nodejs$php$bun$golang$python)$line_break$character";
          right_format = "";

          # 1. Prompt Character
          character = {
            success_symbol = "[   ](green)";
            error_symbol = "[   ](red)";
            vimcmd_symbol = "[   ](purple)";
          };

          # 2. Hostname, Directory & Sudo
          hostname = {
            ssh_only = false;
            ssh_symbol = "󰛳 ";
            format = "[$ssh_symbol$hostname]($style) in ";
            style = "green";
          };

          directory = {
            style = "blue";
            truncation_length = 3;
            truncation_symbol = "";
          };

          sudo = {
            disabled = false;
            format = "as [$symbol]($style)";
            symbol = "# ";
            style = "red";
          };

          cmd_duration = {
            min_time = 2000;
            format = "took [$duration]($style) ";
            style = "yellow";
          };

          # 3. Git (dengan warna terpisah per simbol status)
          git_branch = {
            symbol = " ";
            format = "on [$symbol$branch]($style) ";
            style = "bright-white";
          };

          git_commit = {
            only_detached = true;
            format = "[\\($hash$tag\\)]($style) ";
            style = "green";
          };

          git_state = {
            format = "[\\($state( $progress_current/$progress_total)\\)]($style) ";
            style = "yellow";
            rebase = "REBASING";
            merge = "MERGING";
            revert = "REVERTING";
            cherry_pick = "CHERRY-PICKING";
            bisect = "BISECTING";
            am = "AM";
            am_or_rebase = "AM/REBASE";
          };

          git_metrics = {
            disabled = false;
            added_style = "green";
            deleted_style = "red";
            only_nonzero_diffs = true;
            format = "([+$added]($added_style) [-$deleted]($deleted_style) )";
          };

          git_status = {
            format = "([\\[](#6c7086)[$stashed](purple)[$conflicted](bright-red)[$deleted](red)[$modified](yellow)[$staged](green)[$renamed](blue)[$untracked](bright-magenta)[$ahead_behind](cyan)[\\]](#6c7086) )";
            conflicted = " ";
            untracked = " ";
            modified = " ";
            staged = " ";
            renamed = "➜ ";
            deleted = " ";
            stashed = " ";
            ahead = "⇡\${count} ";
            behind = "⇣\${count} ";
            diverged = "⇕⇡\${ahead_count}⇣\${behind_count} ";
            up_to_date = "";
          };

          # 4. Nix devShell & Flake (memiliki trailing separator ' | ' hanya jika ada environment berikutnya)
          nix_shell = {
            disabled = false;
            format = "[$symbol$state(\\($name\\))]($style)[ | ](bright-black)";
            symbol = " ";
            impure_msg = "impure";
            pure_msg = "pure";
            style = "cyan";
          };

          custom.flake = {
            detect_files = [ "flake.nix" ];
            command = "echo flake";
            symbol = "❄️ ";
            format = "[$symbol$output]($style) ";
            style = "bright-blue";
          };

          # 5. Bahasa Pemrograman (dipisahkan dengan ' | ' antar-environment)
          nodejs = {
            format = "[$symbol($version)]($style) ";
            symbol = " ";
            style = "green";
          };

          php = {
            format = "[| ](bright-black)[$symbol($version)]($style) ";
            symbol = " ";
            style = "purple";
          };

          bun = {
            format = "[| ](bright-black)[$symbol($version)]($style) ";
            symbol = " ";
            style = "yellow";
          };

          golang = {
            format = "[| ](bright-black)[$symbol($version)]($style) ";
            symbol = " ";
            style = "cyan";
          };

          python = {
            format = "[| ](bright-black)[$symbol$pyenv_prefix($version)(\\($virtualenv\\))]($style) ";
            symbol = " ";
            style = "yellow";
          };
        };
      };
    };
}
