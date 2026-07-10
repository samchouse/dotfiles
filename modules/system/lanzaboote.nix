{ lib, inputs, ... }: {
  flake-file.inputs.lanzaboote = {
    url = "github:nix-community/lanzaboote/v1.1.0";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.lanzaboote = {
    nixos = { pkgs, ... }: {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      environment.systemPackages = with pkgs; [ sbctl ];

      boot = {
        loader.systemd-boot.enable = lib.mkForce false;
        lanzaboote = {
          enable = true;
          configurationLimit = 10;
          pkiBundle = "/var/lib/sbctl";
        };
      };
    };
  };
}
