{
  description = "Sam's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs?ref=nixos-unstable-small";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    niqspkgs.url = "github:diniamo/niqspkgs";
    catppuccin.url = "github:catppuccin/nix";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:samchouse/sops-nix";
    custom-fonts.url = "git+ssh://git@github.com/samchouse/fonts.git?ref=main";
    caddy-nixos = {
      url = "github:samchouse/caddy-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    age-plugin-op = {
      url = "github:samchouse/age-plugin-op";
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
      hyprland,
      treefmt-nix,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      overlay-small = final: prev: {
        small = import nixpkgs-small {
          config.allowUnfree = true;
          localSystem = { inherit system; };
        };
      };

      configuration = {
        inherit system;

        modules = [
          (
            { config, pkgs, ... }:
            {
              nixpkgs.overlays = [ overlay-small ];
            }
          )

          ./hosts/desktop
          sops-nix.nixosModules.sops

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
              inherit hyprland;
            };
          }
        ];
        specialArgs = {
          inherit hyprland;
          inherit caddy-nixos;
          inherit age-plugin-op;
        };
      };
    in
    {
      nixosConfigurations.simple = nixpkgs.lib.nixosSystem configuration;
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem (
        configuration
        // {
          specialArgs = configuration.specialArgs // {
            inherit custom-fonts;
          };
        }
      );

      formatter.${system} =
        (treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs = {
            shfmt.enable = true;
            nixfmt.enable = true;
            shellcheck.enable = true;
          };
          settings.on-unmatched = "debug";
        }).config.build.wrapper;
    };
}
