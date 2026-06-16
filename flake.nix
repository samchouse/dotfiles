{
  description = "Sam's Nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-staging.url = "github:nixos/nixpkgs/staging-next";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-sunshine.url = "github:NixOS/nixpkgs/refs/pull/521906/head";

    import-tree.url = "github:denful/import-tree";
    den.url = "github:denful/den";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    hyprland.url = "github:hyprwm/Hyprland";
    vicinae.url = "github:vicinaehq/vicinae";
    flake-parts.url = "github:hercules-ci/flake-parts";
    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niqspkgs = {
      url = "github:diniamo/niqspkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    age-plugin-op = {
      url = "github:samchouse/age-plugin-op";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    custom-fonts = {
      url = "git+ssh://git@github.com/samchouse/fonts.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        {
          pkgs,
          ...
        }:
        {
          formatter = pkgs.treefmt;
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              git
              nil
              nixd
              biome
              shfmt
              nixfmt
              treefmt
              shellcheck
              typescript
              nodejs_latest
            ];
          };
        };
      flake =
        (inputs.nixpkgs.lib.evalModules {
          specialArgs.inputs = inputs;
          modules = [
            inputs.den.flakeOutputs.flake
            (inputs.import-tree ./modules)
          ];
        }).config.flake;
    };
}
