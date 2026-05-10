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

    devenv.url = "github:samchouse/devenv";
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
      inputs = patcher.patch unpatchedInputs { };
      inherit (inputs)
        ags
        astal
        devenv
        nixpkgs
        vicinae
        niqspkgs
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
          permittedInsecurePackages = [
            "openssl-1.1.1w"
          ];
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
                  devenv = devenv.packages.${system}.default;
                  vicinae = vicinae.packages.${system}.default;
                  zen-browser = zen-browser.packages.${system}.default;
                  age-plugin-op = age-plugin-op.defaultPackage.${system};

                  # https://github.com/NixOS/nixpkgs/issues/226575#issuecomment-2813539847
                  logiops = prev.logiops.overrideAttrs (old: {
                    patches = (old.patches or [ ]) ++ [
                      (prev.fetchpatch {
                        name = "bolt_receiver_fix.patch";
                        url = "https://github.com/PixlOne/logiops/pull/460.patch";
                        hash = "sha256-A+StDD+Dp7lPWVpuYR9JR5RuvwPU/5h50B0lY8Qu7nY=";
                      })
                    ];
                  });

                  sweet = pkgs.callPackage ./pkgs/sweet { };
                  openrgb-plugin-visual-map = prev.callPackage ./pkgs/openrgb-plugin-visual-map { };

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
          shellcheck
          nixfmt
          treefmt
          nodejs_25
          typescript
        ];
      };
    };
}
