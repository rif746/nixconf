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
        format = "[$hostname$directory$sudo$cmd_duration]()($git_branch $git_commit$git_state$git_metrics$git_status)( [via ](dimmed white)$nodejs$php$bun$golang$python)()$line_break[   ](bold green)";
        right_format = "";

        git_metrics = {
          disabled = false;
          added_style = "bold green";
          deleted_style = "bold red";
          only_nonzero_diffs = true;
          format = "([+$added]($added_style) [-$deleted]($deleted_style) )";
        };

        bun = {
          format = "[ | ](dimmed white)[$symbol($version )]($style)";
          symbol = " ";
        };

        character = {
          success_symbol = "[❯](purple)";
          error_symbol = "[❯](red)";
          vimcmd_symbol = "[❮](green)";
        };

        cmd_duration = {
          style = "dimmed yellow";
        };

        directory = {
          style = "blue";
        };

        git_branch = {
          format = "[$branch]($style)";
          style = "dimmed bright-white";
        };

        git_commit = {
          only_detached = false;
        };

        git_state = {
          format = "([\\($state( $progress_current/$progress_total)\\)]($style) )";
          style = "bold yellow";
          rebase = "REBASING";
          merge = "MERGING";
          revert = "REVERTING";
          cherry_pick = "CHERRY-PICKING";
          bisect = "BISECTING";
          am = "AM";
          am_or_rebase = "AM/REBASE";
        };

        git_status = {
          format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
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
          format = "[ | ](dimmed white)[$symbol($version)]($style)";
          symbol = " ";
          style = "bold blue";
        };

        hostname = {
          ssh_only = false;
          ssh_symbol = "󰛳 ";
          style = "bold green";
        };

        java = {
          format = "[ | ](dimmed white)[$symbol($version)]($style)";
          symbol = "󰬷 ";
          style = "bold bright-blue";
        };

        nodejs = {
          format = "[$symbol($version)]($style)";
          style = "bold bright-blue";
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
          format = "[ | ](dimmed white)[$symbol($version)]($style)";
          symbol = " ";
          style = "bold blue";
        };

        python = {
          style = "bold blue";
          format = "[ | ](dimmed white)[$symbol$pyenv_prefix($version)(\\($virtualenv\\))]($style)";
        };

        nix_shell = {
          format = "[ | ](dimmed white)[$symbol$state(\\($name\\))]($style)";
          symbol = "❄️  ";
        };

        sudo = {
          disabled = false;
          symbol = "[# ]($style)";
          style = "bold red";
        };
      };
    };
  };
}
