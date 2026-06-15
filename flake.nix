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
    flake-input-patcher = {
      url = "github:jfly/flake-input-patcher";
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
    inputs@{
      self,
      flake-parts,
      flake-input-patcher,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
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
        let
          den =
            (inputs.nixpkgs.lib.evalModules {
              modules = [
                (inputs.import-tree ./modules)
                inputs.den.flakeOutputs.flake
              ];
              specialArgs.inputs = inputs;
            }).config;

          inherit (den.den.hosts.x86_64-linux) desktop;
        in
        {
          nixosConfigurations =
            let
              system = "x86_64-linux";

              patcher = flake-input-patcher.lib.${system};
              inputs = patcher.patch {
                unpatchedInputs = self;

                flakePath = ./.;
                patchSpec = {
                  nixpkgs.patches = [
                    (patcher.fetchpatch {
                      name = "sunshine_2026.patch";
                      url = "https://github.com/NixOS/nixpkgs/pull/521906.diff";
                      hash = "sha256-+/OHCsSzrqwBJeHIbY3B1joe7eKrLg/Y3SxoDxMMgXc=";
                    })
                  ];
                };
              };
              inherit (inputs)
                ags
                astal
                nixpkgs
                vicinae
                niqspkgs
                hyprland
                sops-nix
                copyparty
                catppuccin
                zen-browser
                home-manager
                custom-fonts
                age-plugin-op
                nixpkgs-small
                nixpkgs-staging
                ;

              pkgs-config = {
                inherit system;
                config = {
                  cudaSupport = true;
                  allowUnfree = true;
                };
              };
              pkgs = import nixpkgs pkgs-config;

              configuration = {
                inherit system;

                modules = [
                  {
                    nixpkgs = {
                      pkgs = pkgs;
                      overlays = [
                        copyparty.overlays.default
                        (final: prev: {
                          astal = astal.packages.${system};
                          niqs = niqspkgs.packages.${system};
                          vicinae = vicinae.packages.${system}.default;
                          zen-browser = zen-browser.packages.${system}.default;
                          age-plugin-op = age-plugin-op.defaultPackage.${system};

                          hyprland = hyprland.packages.${system}.hyprland;
                          xdg-desktop-portal-hyprland = hyprland.packages.${system}.xdg-desktop-portal-hyprland;

                          sweet = pkgs.callPackage ./pkgs/sweet { };

                          small = import nixpkgs-small pkgs-config;
                          staging = import nixpkgs-staging pkgs-config;
                        })
                      ];
                    };
                  }

                  ./hosts/desktop
                  sops-nix.nixosModules.sops
                  copyparty.nixosModules.default

                  home-manager.nixosModules.home-manager
                  {
                    home-manager.users.root.imports = [ ./home/root ];
                    home-manager.users.sam.imports = [
                      ./home/sam
                      ags.homeManagerModules.default
                      catppuccin.homeModules.catppuccin
                      vicinae.homeManagerModules.default
                    ];
                  }

                  desktop.mainModule
                ];
              };
            in
            {
              simple = nixpkgs.lib.nixosSystem configuration;
              desktop = nixpkgs.lib.nixosSystem (
                configuration
                // {
                  specialArgs = {
                    inherit custom-fonts;
                  };
                }
              );
            };

          inherit (den.flake) darwinConfigurations;
        };
    };
}
