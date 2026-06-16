{ inputs, lib, ... }: {
  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    den.url = "github:denful/den";
  };

  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.den.flakeModule
  ];
}
