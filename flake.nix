{
  description = "Sam's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprlock = {
      url = "github:hyprwm/hyprlock";
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
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: https://github.com/Mic92/sops-nix/issues/576
    sops-nix = {
      url = "github:samchouse/sops-nix";
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

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixvim,
      nixpkgs,
      hyprland,
      hyprlock,
      niqspkgs,
      sops-nix,
      catppuccin,
      zen-browser,
      treefmt-nix,
      home-manager,
      custom-fonts,
      age-plugin-op,
      nixpkgs-small,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      configuration = {
        inherit system;

        modules = [
          {
            nixpkgs.overlays = [
              (_: _: {
                niqs = niqspkgs.packages.${system};
                zen-browser = zen-browser.packages.${system}.default;
                age-plugin-op = age-plugin-op.defaultPackage.${system};
                hypr = hyprland.packages.${system} // {
                  hyprlock = hyprlock.packages.${system}.default;
                };

                small = import nixpkgs-small {
                  config.allowUnfree = true;
                  localSystem = {
                    inherit system;
                  };
                };
              })
            ];
          }

          ./hosts/desktop
          sops-nix.nixosModules.sops

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.users.root.imports = [ ./home/root ];
            home-manager.users.sam.imports = [
              ./home/sam
              catppuccin.homeModules.catppuccin
              nixvim.homeManagerModules.nixvim
            ];
          }
        ];
      };
    in
    {
      nixosConfigurations.simple = nixpkgs.lib.nixosSystem configuration;
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem (
        configuration
        // {
          specialArgs = {
            inherit custom-fonts;
          };
        }
      );

      formatter.${system} = treefmtEval.config.build.wrapper;
      checks.${system} = {
        formatting = treefmtEval.config.build.check self;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ treefmtEval.config.build.wrapper ];
      };
    };
}
