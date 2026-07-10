{ inputs, ... }: {
  flake-file.inputs.copyparty = {
    url = "github:9001/copyparty";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.copyparty = {
    nixos = { config, ... }: {
      imports = [
        inputs.copyparty.nixosModules.default
      ];

      nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

      services.copyparty = {
        enable = true;
        user = "sam";
        group = "users";
        accounts.sam.passwordFile = config.sops.secrets."copyparty_password".path;
        settings = {
          rproxy = 1;
          e2ts = true;
          e2vu = true;
          e2dsa = true;
          i = "0.0.0.0";
          shr = "/share";
          xff-src = "lan";
          no-robots = true;
          xff-hdr = "cf-connecting-ip";
          site="https://srv.xenfo.dev/";
        };
        globalExtraConfig = ''
          ipu: 100.64.0.0/10=sam
          ipu: 192.168.2.2/32=sam
        '';
        volumes = {
          "/" = {
            path = "/srv/copyparty";
            access = {
              rw = "*";
              A = "sam";
            };
          };
          "/desktop" = {
            path = "/home/sam";
            access.A = "sam";
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
