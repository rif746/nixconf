{ ... }: {
  flake.homeModules.desktop-plasma =
    {
      config,
      pkgs,
      lib,
      osConfig ? { },
      ...
    }:
    let
      cfg = osConfig.nixos.desktop.plasma or { enable = false; };
    in
    {
      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          (import ./partials/_plasma.nix { inherit pkgs lib config; })
          (import ./partials/_konsole.nix { inherit pkgs lib config; })

          {
            home = {
              file.".local/share/icons/default" = {
                source = "${pkgs.kdePackages.breeze}/share/icons/breeze_cursors/";
                recursive = true;
              };

              packages = with pkgs; [
                (python314.withPackages (
                  ps: with ps; [
                    dbus-python
                    pygobject3
                  ]
                ))
              ];
            };
          }
        ]
      );
    };
}
