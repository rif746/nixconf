{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    home-manager.url = "github:nix-community/home-manager";
    llm-agents.url = "github:numtide/llm-agents.nix";
    stylix.url = "github:nix-community/stylix";
    nixvim.url = "github:nix-community/nixvim";
    rif-nixvim.url = "path:/home/syarif/Projects/nvim-nix/";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # Register flake.homeModules support with flake-parts
        inputs.home-manager.flakeModules.home-manager

        # Auto-import folder modules
        (inputs.import-tree ./modules)
      ];
    };
}
