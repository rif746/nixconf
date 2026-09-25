{ ... }: {
  flake.nixosModules.cli-git = { pkgs, config, ... }: {
    programs.git = {
      enable = true;
      config = {
        user = {
          name = "Syarif Ubaidillah";
          email = "ubed56pb@gmail.com";
        };
        init = {
          defaultBranch = "master";
        };
        pull = {
          rebase = true; # Merge on pull by default
        };
        core = {
          editor = "vim";
        };
      };
    };

    system.userActivationScripts.gitconfigLink = {
      text = ''
        if [ ! -f /home/syarif/.gitconfig ]; then
          cp ${pkgs.git}/etc/gitconfig ${config.users.users.syarif.home}/.gitconfig
        fi
      '';
    };
  };
}
