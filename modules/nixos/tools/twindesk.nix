{ inputs, ... }: {
  flake.nixosModules.tools-twindesk =
    {
      config,
      lib,
      pkgs,
      user,
      ...
    }:
    let
      cfg = config.nixos.tools.twindesk;
    in
    {
      imports = [
        inputs.twindesk.nixosModules.default
      ];

      options.nixos.tools.twindesk = {
        enable = lib.mkEnableOption "Your Mac, PC, Linux box, Android phone and iPhone, working as one desk";
      };

      config = lib.mkIf cfg.enable {
        programs.twindesk = {
          enable = true;
          user = user.name;
          openFirewall = true;
          enableWifiDirect = true;
          virtualCamera = true;
          uinput = true;
        };
      };
    };
}
