{
  lib,
  ...
}:
{
  virtualisation.oci-containers = {
    containers = {
      twenty-server = {
        image = "twentycrm/twenty:v0.51";
        ports = [ "3625:3000" ];
        volumes = [ "twenty-docker:/app/docker-data" ];
        networks = [ "twenty" ];
      };
      twenty-server-init = {
        image = "twentycrm/twenty:v0.51";
        networks = [ "twenty" ];
        volumes = [ "twenty-docker:/app/docker-data" ];
        user = "root";
        cmd = [
          "sh"
          "-c"
          ''
            chown -R 1000:1000 /app/docker-data

            apk update
            apk add build-base g++ cairo-dev pango-dev giflib-dev python3
            yarn
            yarn command:prod workspace:sync-metadata 
          ''
        ];
      };
      twenty-worker = {
        image = "twentycrm/twenty:v0.51";
        networks = [ "twenty" ];
        cmd = [
          "yarn"
          "worker:prod"
        ];
      };
      twenty-db = {
        image = "postgres:16.8-alpine"; # pinned
        volumes = [ "twenty-db:/var/lib/postgresql/data" ];
        networks = [ "twenty" ];
        environment = {
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD = "postgres";
        };
      };
      twenty-redis = {
        image = "redis:7.4.2-alpine";
        networks = [ "twenty" ];
      };
    };
  };

  systemd.services.docker-twenty-server-init = {
    serviceConfig = {
      Restart = lib.mkForce "on-failure";
    };
  };
}
