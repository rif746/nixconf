{ ... }: {
  # Terdaftar otomatis ke self.nixosModules.cli-llm via flake-parts & import-tree
  flake.homeModules.cli-llm =
    {
      config,
      lib,
      inputs,
      pkgs,
      ...
    }:
    let
      cfg = config.features.cli.llm;
    in
    {
      options.features.cli.llm = {
        enable = lib.mkEnableOption "LLM CLI Tools";

        junie.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "JetBrains Junie CLI";
        };
        opencode.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "OpenCode AI Agent";
        };
        antigravity.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Google Antigravity CLI";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
            (lib.optional cfg.junie.enable junie) ++
            (lib.optional cfg.opencode.enable opencode) ++
            (lib.optional cfg.antigravity.enable antigravity-cli);
      };
    };
}
