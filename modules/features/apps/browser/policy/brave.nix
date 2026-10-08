{ ... }: {
  # Otomatis terdaftar ke self.nixosModules.system-brave-policy via import-tree
  flake.nixosModules.system-brave-policy = { config, lib, pkgs, ... }: let
    cfg = config.modules.system.brave-policy;
  in {
    options.modules.system.brave-policy.enable = lib.mkEnableOption "Brave enterprise managed policies (Anti-AI & Anti-Bloatware)";

    # File /etc HANYA akan dibuat jika cfg.enable bernilai TRUE
    config = lib.mkIf cfg.enable {
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
