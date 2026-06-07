{
  description = "Sam's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-staging.url = "github:nixos/nixpkgs/staging-next";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    vicinae.url = "github:vicinaehq/vicinae";
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
    unpatchedInputs:
    let
      system = "x86_64-linux";

      patcher = unpatchedInputs.flake-input-patcher.lib.${system};
      inputs = patcher.patch {
        inherit unpatchedInputs;
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
                (final: prev: {
                  astal = astal.packages.${system};
                  niqs = niqspkgs.packages.${system};
                  vicinae = vicinae.packages.${system}.default;
                  zen-browser = zen-browser.packages.${system}.default;
                  age-plugin-op = age-plugin-op.defaultPackage.${system};

                  xdg-desktop-portal-hyprland = hyprland.packages.${system}.xdg-desktop-portal-hyprland;
                  hyprland = hyprland.packages.${system}.hyprland.overrideAttrs (old: {
                    src = prev.fetchFromGitHub {
                      owner = "hyprwm";
                      repo = "hyprland";
                      fetchSubmodules = true;
                      rev = old.env.GIT_COMMIT_HASH;
                      hash = "sha256-sHtVg0Fpvd8dFcI5oKGYwe4zEYxgS2LwhWVzwDXePpc=";
                    };

                    patchPhase = ''
                      ${prev.git}/bin/git init -qb main
                      ${prev.git}/bin/git add -A
                      ${prev.git}/bin/git apply ${
                        prev.fetchurl {
                          url = "https://github.com/hyprwm/Hyprland/pull/14547.diff";
                          hash = "sha256-QRXgsZmBl310alMaLRnk3zqcPBgaurFgJdk9+wPcQnQ=";
                        }
                      }
                    '';
                  });

                  sweet = pkgs.callPackage ./pkgs/sweet { };

                  small = import nixpkgs-small pkgs-config;
                  staging = import nixpkgs-staging pkgs-config;
                })
              ];
            };
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
              ags.homeManagerModules.default
              catppuccin.homeModules.catppuccin
              vicinae.homeManagerModules.default
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

      formatter.${system} = pkgs.treefmt;
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
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
}
