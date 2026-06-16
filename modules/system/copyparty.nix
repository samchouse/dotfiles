{ inputs, ... }: {
  den.aspects.copyparty = {
    nixos = {
      imports = [
        inputs.copyparty.nixosModules.default
      ];

      nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

      services.copyparty = {
        enable = true;
        user = "sam";
        group = "users";
        settings = {
          i = "100.82.217.30";
          e2ts = true;
          e2vu = true;
          e2dsa = true;
        };
        volumes = {
          "/" = {
            path = "/srv/copyparty";
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

      systemd.tmpfiles.rules = [
        "d /srv/copyparty 0755 sam users -"
      ];
    };
  };
}
