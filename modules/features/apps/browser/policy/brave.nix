{ ... }: {
  flake.nixosModules.system-brave-policy =
    {
      config,
      user,
      lib,
      pkgs,
      ...
    }:
    let
      userHomeConfig = config.home-manager.users.${user.name} or { };
      isBraveEnabled = userHomeConfig.features.apps.browser.brave.enable;
    in
    {
      config = lib.mkIf isBraveEnabled {
        environment.etc."brave/policies/managed/default.json".text = builtins.toJSON {
          BraveAIChatEnabled = false;
          BraveRewardsDisabled = true;
          BraveWalletDisabled = true;
          BraveVPNDisabled = true;
          BraveNewsDisabled = true;
          MetricsReportingEnabled = false;
          PromotionsEnabled = false;
        };
      };
    };
}
