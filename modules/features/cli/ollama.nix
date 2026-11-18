{ inputs, ... }: {
  flake.homeModules.cli-ollama =
    {
      config,
      lib,
      pkgs,
      user,
      ...
    }:
    let
      cfg = config.features.cli.ollama;
    in
    {
      options.features.cli.ollama = {
        enable = lib.mkEnableOption "Ollama server for local AI";
      };

      config = lib.mkIf cfg.enable {
        services.ollama = {
          enable = true;
          package = pkgs.ollama-vulkan;
        };
      };
    };
}
