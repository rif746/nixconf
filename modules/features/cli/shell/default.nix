{ ... }: {
  flake.homeModules.shell = { pkgs, user, ... }: {
    imports = [
      (./. + "/_${user.shell}.nix")
    ];

    home = {
      packages = [
        pkgs.devenv
      ];
      shellAliases = {
        rebuild = "sudo nixos-rebuild switch --flake .";
        nix-clear = "sudo nix-collect-garbage -d";
        c = "clear";
        g = "git";
      };
    };

    programs.starship = {
      enable = true;
      settings = {
        "$schema" = "https://starship.rs/config-schema.json";
        # Remapped format strings to inherit standard Base16 terminal color slots
        format = "[$hostname$directory$sudo$cmd_duration]()($git_branch $git_commit$git_state$git_metrics$git_status)( [via ](bright-black)$nodejs$php$bun$golang$python)()$line_break[   ](green)";
        right_format = "";

        git_metrics = {
          disabled = false;
          added_style = "green";
          deleted_style = "red";
          only_nonzero_diffs = true;
          format = "([+$added]($added_style) [-$deleted]($deleted_style) )";
        };

        bun = {
          format = "[ | ](bright-black)[$symbol($version )]($style)";
          symbol = " ";
          style = "yellow";
        };

        character = {
          success_symbol = "[❯](purple)";
          error_symbol = "[❯](red)";
          vimcmd_symbol = "[❮](green)";
        };

        cmd_duration = {
          style = "yellow";
        };

        directory = {
          style = "blue";
        };

        git_branch = {
          format = "[$branch]($style)";
          style = "bright-white";
        };

        git_commit = {
          only_detached = false;
        };

        git_state = {
          format = "([\\($state( $progress_current/$progress_total)\\)]($style) )";
          style = "yellow";
          rebase = "REBASING";
          merge = "MERGING";
          revert = "REVERTING";
          cherry_pick = "CHERRY-PICKING";
          bisect = "BISECTING";
          am = "AM";
          am_or_rebase = "AM/REBASE";
        };

        git_status = {
          format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](bright-magenta) ($ahead_behind$stashed)]($style)";
          style = "cyan";
          conflicted = " ";
          untracked = " ";
          modified = " ";
          staged = " ";
          renamed = "➜ ";
          deleted = " ";
          stashed = " ";
        };

        golang = {
          format = "[ | ](bright-black)[$symbol($version)]($style)";
          symbol = " ";
          style = "blue";
        };

        hostname = {
          ssh_only = false;
          ssh_symbol = "󰛳 ";
          style = "green";
        };

        java = {
          format = "[ | ](bright-black)[$symbol($version)]($style)";
          symbol = "󰬷 ";
          style = "blue";
        };

        nodejs = {
          format = "[$symbol($version)]($style)";
          style = "blue";
        };

        os = {
          disabled = false;
          format = "[$symbol]($style)$name ";
          symbols = {
            Alpine = " ";
            Android = " ";
            CachyOS = " ";
            NixOS = " ";
          };
        };

        php = {
          format = "[ | ](bright-black)[$symbol($version)]($style)";
          symbol = " ";
          style = "purple";
        };

        python = {
          style = "blue";
          format = "[ | ](bright-black)[$symbol$pyenv_prefix($version)(\\($virtualenv\\))]($style)";
        };

        nix_shell = {
          format = "[ | ](bright-black)[$symbol$state(\\($name\\))]($style)";
          symbol = "❄️  ";
          style = "cyan";
        };

        sudo = {
          disabled = false;
          symbol = "[# ]($style)";
          style = "red";
        };
      };
    };
  };
}
