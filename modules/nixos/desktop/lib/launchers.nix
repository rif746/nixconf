# modules/nixos/desktop/default.nix
{ lib, ... }:
let
  mkLaunchers =
    {
      userCfg,
      osCfg ? { },
    }:
    let
      optionalLaunchers = [
        {
          cond =
            (userCfg.features.apps.browser.enable or false)
            && (userCfg.features.apps.browser.firefox.enable or false);
          desktop = "firefox.desktop";
        }
        {
          cond =
            (userCfg.features.apps.browser.enable or false)
            && (userCfg.features.apps.browser.brave.enable or false);
          desktop = "brave-browser.desktop";
        }
        {
          cond = userCfg.features.apps.communication.enable or false;
          desktop = "ferdium.desktop";
        }
        {
          cond = (osCfg.nixos.tools.gaming.enable or false) || (osCfg.modules.gaming.enable or false);
          desktop = "steam.desktop";
        }
        {
          cond = userCfg.features.apps.jetbrains.android-studio.enable or false;
          desktop = "android-studio.desktop";
        }
        {
          cond = userCfg.features.apps.jetbrains.phpstorm.enable or false;
          desktop = "phpstorm.desktop";
        }
        {
          cond = userCfg.features.apps.jetbrains.datagrip.enable or false;
          desktop = "datagrip.desktop";
        }
        {
          cond = userCfg.features.apps.jetbrains.pycharm.enable or false;
          desktop = "pycharm.desktop";
        }
        {
          cond = userCfg.features.apps.jetbrains.goland.enable or false;
          desktop = "goland.desktop";
        }
        {
          cond = osCfg.modules.gaming.steam.enable or false;
          desktop = "steam.desktop";
        }
      ];
    in
    map (x: x.desktop) (builtins.filter (x: x.cond) optionalLaunchers);
in
{
  flake.nixosModules.desktop-launchers =
    { config, ... }:
    let
      hmUsers = lib.attrValues (config.home-manager.users or { });
    in
    {
      options.nixos.desktop.optionalLaunchers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        readOnly = true;
        default = lib.unique (
          lib.concatMap (
            u:
            mkLaunchers {
              userCfg = u;
              osCfg = config;
            }
          ) hmUsers
        );
      };
    };

  flake.homeModules.desktop-launchers =
    { config, osConfig, ... }:
    {
      options.features.desktop.optionalLaunchers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        readOnly = true;
        default = mkLaunchers {
          userCfg = config;
          osCfg = osConfig;
        };
      };
    };
}
