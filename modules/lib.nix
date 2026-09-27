{ inputs, ... }:
let
  config = {
    cudaSupport = true;
    allowUnfree = true;
  };

  mkPkgsConfig = system: { inherit system config; };
in
{
  flake-file.inputs = {
    nixpkgs-staging.url = "github:nixos/nixpkgs/staging-next";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";

    age-plugin-op = {
      url = "github:samchouse/age-plugin-op";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.lib.mkPkgsConfig = mkPkgsConfig;
  flake.lib.mkNixpkgs = {
    inherit config;
    overlays = [
      (
        final: prev:
        let
          system = prev.stdenv.hostPlatform.system;
        in
        {
          age-plugin-op = inputs.age-plugin-op.defaultPackage.${system};

          small = import inputs.nixpkgs-small (mkPkgsConfig system);
          staging = import inputs.nixpkgs-staging (mkPkgsConfig system);
        }
      )
    ];
  };
}
