{
  description = "Sam's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-old.url = "github:nixos/nixpkgs/df372dcaba0309fd081f19bf6490e27ac186078c";
    home-manager = {
      url = "github:nix-community/home-manager";
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
  };

  outputs =
    {
      ags,
      astal,
      nixvim,
      nixpkgs,
      niqspkgs,
      sops-nix,
      catppuccin,
      zen-browser,
      nixpkgs-old,
      home-manager,
      custom-fonts,
      age-plugin-op,
      nixpkgs-small,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          cudaSupport = true;
          allowUnfree = true;
        };
      };

      openrgb-version = "1.0rc2";
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
                  zen-browser = zen-browser.packages.${system}.default;
                  age-plugin-op = age-plugin-op.defaultPackage.${system};
                  hyprlock = nixpkgs-old.legacyPackages.${system}.hyprlock;

                  sweet = pkgs.callPackage ./pkgs/sweet { };

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

                  openrgb = prev.openrgb.overrideAttrs (old: rec {
                    version = openrgb-version;
                    src = prev.fetchFromGitLab {
                      owner = "CalcProgrammer1";
                      repo = "OpenRGB";
                      rev = "release_candidate_${version}";
                      hash = "sha256-vdIA9i1ewcrfX5U7FkcRR+ISdH5uRi9fz9YU5IkPKJQ=";
                    };

                    patches = [ ./patches/openrgb_systemd.patch ];

                    postPatch = ''
                      patchShebangs scripts/build-udev-rules.sh
                      substituteInPlace scripts/build-udev-rules.sh \
                        --replace-fail /usr/bin/env "${prev.coreutils}/bin/env"
                    '';

                    qmakeFlags = old.qmakeFlags ++ [
                      "OPENRGB_SYSTEM_PLUGIN_DIRECTORY=${
                        toString (
                          prev.symlinkJoin {
                            name = "openrgb-plugins";
                            paths = [
                              final.openrgb-plugin-effects
                              final.openrgb-plugin-visual-map
                            ];
                            # Remove all library version symlinks except one,
                            # or they will result in duplicates in the UI.
                            # We leave the one pointing to the actual library, usually the most
                            # qualified one (eg. libOpenRGBHardwareSyncPlugin.so.1.0.0).
                            postBuild = ''
                              for f in $out/lib/*; do
                                if [ "$(dirname $(readlink "$f"))" == "." ]; then
                                  rm "$f"
                                fi
                              done
                            '';
                          }
                        )
                      }/lib/openrgb/plugins"
                    ];
                  });
                  openrgb-plugin-effects = prev.openrgb-plugin-effects.overrideAttrs (old: rec {
                    version = openrgb-version;
                    src = prev.fetchFromGitLab {
                      owner = "OpenRGBDevelopers";
                      repo = "OpenRGBEffectsPlugin";
                      rev = "release_candidate_${version}";
                      hash = "sha256-0W0hO3PSMpPLc0a7g/Nn7GWMcwBXhOxh1Y2flpdcnfE=";
                      fetchSubmodules = true;
                    };

                    patches = [ ];
                    postPatch = "";

                    buildInputs = old.buildInputs ++ [ prev.pipewire.dev ];

                    CPATH = "${prev.pipewire.dev}/include/pipewire-0.3:${prev.pipewire.dev}/include/spa-0.2";
                    qmakeFlags = [
                      "QT_TOOL.lrelease.binary=${prev.lib.getDev prev.kdePackages.qttools}/bin/lrelease"
                    ];
                  });
                  openrgb-plugin-visual-map = prev.callPackage ./pkgs/openrgb-plugin-visual-map {
                    version = openrgb-version;
                  };

                  small = import nixpkgs-small {
                    inherit system;
                  };
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
              catppuccin.homeModules.catppuccin
              nixvim.homeModules.nixvim
              ags.homeManagerModules.default
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
          nixfmt-rfc-style
          treefmt
        ];
      };
    };
}
