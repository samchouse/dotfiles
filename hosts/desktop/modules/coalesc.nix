{
  lib,
  ...
}:
{
  virtualisation.oci-containers = {
    containers = {
      twenty-server-init = {
        image = "twentycrm/twenty:v0.52";
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
      twenty-server = {
        image = "twentycrm/twenty:v0.52";
        ports = [ "3625:3000" ];
        volumes = [ "twenty-docker:/app/docker-data" ];
        networks = [ "twenty" ];
        environment = {
          DISABLE_DB_MIGRATIONS = "true";
        };
        dependsOn = [ "twenty-server-init" ];
      };
      twenty-worker = {
        image = "twentycrm/twenty:v0.52";
        networks = [ "twenty" ];
        cmd = [
          "yarn"
          "worker:prod"
        ];
        environment = {
          DISABLE_DB_MIGRATIONS = "true";
        };
        dependsOn = [ "twenty-server-init" ];
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
        image = "redis:7.4.3-alpine";
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
