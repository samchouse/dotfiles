{
  description = "Sam's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs?ref=nixos-unstable-small";
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    custom-fonts.url = "git+ssh://git@github.com/samchouse/fonts.git?ref=main";
    niqspkgs.url = "github:diniamo/niqspkgs";
    sops-nix.url = "github:samchouse/sops-nix";
    age-plugin-op = {
      url = "github:samchouse/age-plugin-op";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caddy-nixos = {
      url = "github:samchouse/caddy-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      catppuccin,
      home-manager,
      custom-fonts,
      niqspkgs,
      sops-nix,
      age-plugin-op,
      caddy-nixos,
      nixpkgs-small,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      overlay-small = final: prev: {
        small = nixpkgs-small.legacyPackages.${prev.system};
      };
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

      nixosConfigurations.simple = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/desktop
          sops-nix.nixosModules.sops
          (
            { config, pkgs, ... }:
            {
              nixpkgs.overlays = [ overlay-small ];
            }
          )
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "bak";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sam.imports = [
              ./home/sam
              catppuccin.homeManagerModules.catppuccin
            ];
            home-manager.users.root.imports = [ ./home/root ];
            home-manager.extraSpecialArgs = {
              inherit niqspkgs;
            };
          }
        ];
        specialArgs = {
          inherit age-plugin-op;
          inherit caddy-nixos;
        };
      };

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/desktop
          sops-nix.nixosModules.sops
          (
            { config, pkgs, ... }:
            {
              nixpkgs.overlays = [ overlay-small ];
            }
          )
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "bak";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sam.imports = [
              ./home/sam
              catppuccin.homeManagerModules.catppuccin
            ];
            home-manager.users.root.imports = [ ./home/root ];
            home-manager.extraSpecialArgs = {
              inherit niqspkgs;
            };
          }
        ];
        specialArgs = {
          inherit custom-fonts;
          inherit age-plugin-op;
          inherit caddy-nixos;
        };
      };
    };
}
