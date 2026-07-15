{ den, ... }: {
  den.aspects.filebrowser = {
    includes = [ den.aspects.copyparty ];

    nixos = { config, ... }: {
      virtualisation.oci-containers.containers = {
        filebrowser = {
          image = "gtstef/filebrowser:1.4.0-stable";
          ports = [ "3924:80" ];
          volumes = [
            "/srv:/srv"
            "filebrowser-cache:/srv/cache"
            "filebrowser:/home/filebrowser/data"
            "${./config.yaml}:/home/filebrowser/data/config.yaml"
          ];
          user = "1000:100";
          capabilities.NET_BIND_SERVICE = true;
          autoStart = false;
          environmentFiles = [ config.sops.templates."filebrowser.env".path ];
        };

        eurooffice = {
          image = "ghcr.io/euro-office/documentserver:v9.3.2";
          ports = [ "9880:80" ];
          autoStart = false;
          environmentFiles = [ config.sops.templates."eurooffice.env".path ];
        };
      };
    };
  };
}
