{
  description = "Sam's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-staging.url = "github:nixos/nixpkgs/staging-next";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-old.url = "github:nixos/nixpkgs/df372dcaba0309fd081f19bf6490e27ac186078c";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae.url = "github:vicinaehq/vicinae";
    flake-input-patcher = {
      url = "github:jfly/flake-input-patcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
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
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
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
    hyprshutdown = {
      url = "github:hyprwm/hyprshutdown";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # TODO: https://github.com/Mic92/sops-nix/issues/576
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
      inputs = patcher.patch unpatchedInputs {
        nixpkgs.patches = [
          (patcher.fetchpatch {
            name = "beszel-systemd-monitoring.patch";
            url = "https://github.com/NixOS/nixpkgs/pull/461327.patch";
            hash = "sha256-0EvLrR7x2LTtSl7knqoRgnVNI14UfiiJuILPdXKBrXw=";
          })
        ];
        niri.patches = [
          (patcher.fetchpatch {
            name = "niri-add-extraConfig.patch";
            url = "https://github.com/sodiboo/niri-flake/pull/1467.patch";
            hash = "sha256-3wd5sFMY9kGUeGIfvLpG/fYkzO1H5hXpKJhZiAv4czQ=";
          })
        ];
      };
      inherit (inputs)
        ags
        niri
        astal
        nixvim
        nixpkgs
        vicinae
        niqspkgs
        sops-nix
        catppuccin
        zen-browser
        nixpkgs-old
        hyprshutdown
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
                niri.overlays.niri

                (final: prev: {
                  astal = astal.packages.${system};
                  niqs = niqspkgs.packages.${system};
                  vicinae = vicinae.packages.${system}.default;
                  zen-browser = zen-browser.packages.${system}.default;
                  age-plugin-op = age-plugin-op.defaultPackage.${system};
                  hyprlock = nixpkgs-old.legacyPackages.${system}.hyprlock;
                  hyprshutdown = hyprshutdown.packages.${system}.hyprshutdown;

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
                  quickemu = prev.quickemu.overrideAttrs (old: rec {
                    version = "7ea4e95";
                    src = old.src.override {
                      rev = version;
                      hash = "sha256-pj6YQc7e4I6XvGq/uGGq2z/UhAs3ZeKrsJd8oLWjauA=";
                    };

                    patches = [ ];
                  });
                  beszel =
                    (prev.beszel.override {
                      buildGoModule = final.staging.buildGo126Module;
                    }).overrideAttrs
                      (old: rec {
                        version = "0.18.4";
                        src = old.src.override {
                          tag = "v${version}";
                          hash = "sha256-Ugxy23bLrKIDclrYRFJc6Nq4Ak2S3OLeyMaxuRkS/tY=";
                        };

                        webui = prev.buildNpmPackage {
                          inherit
                            version
                            src
                            ;

                          pname = old.pname;
                          meta = old.meta;

                          npmFlags = [ "--legacy-peer-deps" ];

                          buildPhase = ''
                            runHook preBuild

                            npx lingui extract --overwrite
                            npx lingui compile
                            node --max_old_space_size=1024000 ./node_modules/vite/bin/vite.js build

                            runHook postBuild
                          '';

                          installPhase = ''
                            runHook preInstall

                            mkdir -p $out
                            cp -r dist/* $out

                            runHook postInstall
                          '';

                          sourceRoot = "${src.name}/internal/site";

                          npmDepsHash = "sha256-509/n5OH4z6LZH+jlmDLl2DlqKrD7M5ajtalmF/4n1o=";
                        };

                        vendorHash = "sha256-V9P3VP4CsboaWPIt/MhtxYDsYH3pwKL4xK5YcLKgbI8=";

                        preBuild = ''
                          mkdir -p internal/site/dist
                          cp -r ${webui}/* internal/site/dist
                        '';
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
          niri.nixosModules.niri
          sops-nix.nixosModules.sops

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.users.root.imports = [ ./home/root ];
            home-manager.users.sam.imports = [
              ./home/sam
              nixvim.homeModules.nixvim
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
          nodePackages.typescript
        ];
      };
    };
}
