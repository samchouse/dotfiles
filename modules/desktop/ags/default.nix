{ lib, inputs, ... }: {
  flake-file.inputs = {
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs = {
        astal.follows = "astal";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  den.aspects.ags = {
    homeManager =
      { pkgs, host, ... }:
      lib.optionalAttrs (host.class == "nixos") {
        imports = [
          inputs.ags.homeManagerModules.default
        ];

        programs.ags = {
          enable = true;
          extraPackages = with pkgs.astal; [
            tray
            mpris
            notifd
            network
            hyprland
            bluetooth
            wireplumber
          ];

          configDir = ./.;
        };
      };
  };
}
