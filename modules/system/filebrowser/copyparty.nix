{ inputs, ... }: {
  flake-file.inputs.copyparty = {
    url = "github:9001/copyparty";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.copyparty = {
    nixos = {
      imports = [
        inputs.copyparty.nixosModules.default
      ];

      services = {
        copyparty = {
          enable = true;
          user = "sam";
          group = "users";
          settings = {
            e2ts = true;
            e2vu = true;
            e2dsa = true;
            i = "0.0.0.0";
          };
          volumes = {
            "/" = {
              path = "/srv/share";
              access.A = "*";
            };
            "/desktop" = {
              path = "/home/sam";
              access.A = "*";
              flags = {
                d2d = true;
                d2t = true;
              };
            };
          };
        };
      };

      systemd.tmpfiles.rules = [
        "d /srv/share 0755 sam users -"
      ];
    };
  };
}
