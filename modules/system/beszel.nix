{ lib, ... }: {
  den.aspects.beszel = {
    nixos = { config, ... }: {
      services = {
        beszel = {
          hub = {
            enable = true;
            host = "0.0.0.0";
            port = 7463;
          };
          agent = {
            enable = true;
            environment = {
              HUB_URL = "http://localhost:7463";
              DOCKER_HOST = "http://localhost:2375";
              EXTRA_FILESYSTEMS = "/mnt/secondary__Secondary";
              TOKEN = "885fd152-b855-4924-ae54-bac24f36878a";
              KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpWIT7z6MkRkDOeFLMC9JlBzYbXxM7q+aDOnQiCKdwP";
            };
          };
        };
      };

      systemd.services = {
        beszel-hub = {
          serviceConfig = {
            ExecStartPre = lib.mkForce [
              "${config.services.beszel.hub.package}/bin/beszel-hub migrate up"
              "${config.services.beszel.hub.package}/bin/beszel-hub migrate history-sync"
            ];
          };
        };
        beszel-agent = {
          path = [ config.hardware.nvidia.package ];
          serviceConfig = {
            DeviceAllow = [
              "/dev/nvidiactl rw"
              "/dev/nvidia0 rw"
            ];
          };
        };
      };

      virtualisation.oci-containers.containers.podman-socket-proxy = {
        image = "tecnativa/docker-socket-proxy:v0.4.2";
        volumes = [ "/run/podman/podman.sock:/var/run/docker.sock:ro" ];
        ports = [ "2375:2375" ];
        environment.CONTAINERS = "1";
      };
    };
  };
}
