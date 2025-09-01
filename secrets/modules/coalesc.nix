{
  config,
  ...
}:
let
  utils = import ../utils.nix;

  twentyUnits = [
    "docker-twenty-server.service"
    "docker-twenty-server-init.service"
    "docker-twenty-worker.service"
    "docker-twenty-db.service"
    "docker-twenty-redis.service"
  ];
  typesenseUnits = [ "docker-typesense.service" ];

  twentyOptions = utils.mkOpts twentyUnits;
in
{
  systemd.services.sops-secrets.wants = twentyUnits ++ typesenseUnits;

  sops.secrets."s3_name" = twentyOptions;
  sops.secrets."s3_endpoint" = twentyOptions;
  sops.secrets."app_secret" = twentyOptions;
  sops.secrets."preview_typesense_key" = utils.mkOpts typesenseUnits;

  sops.templates."twenty.env".content = ''
    NODE_PORT=3000
    SERVER_URL=https://crm.coalesc.xyz
    REDIS_URL=redis://twenty-redis:6379
    PG_DATABASE_URL=postgres://postgres:postgres@twenty-db:5432/default

    STORAGE_TYPE=s3
    STORAGE_S3_REGION=auto
    STORAGE_S3_NAME=${config.sops.placeholder.s3_name}
    STORAGE_S3_ENDPOINT=${config.sops.placeholder.s3_endpoint}

    APP_SECRET=${config.sops.placeholder.app_secret}
  '';
  sops.templates."typesense.env".content = ''
    TYPESENSE_API_KEY=${config.sops.placeholder.preview_typesense_key}
  '';

  virtualisation.oci-containers.containers = {
    twenty-server-init = {
      environmentFiles = [ config.sops.templates."twenty.env".path ];
    };
    twenty-server = {
      environmentFiles = [ config.sops.templates."twenty.env".path ];
    };
    twenty-worker = {
      environmentFiles = [ config.sops.templates."twenty.env".path ];
    };
    typesense = {
      environmentFiles = [ config.sops.templates."typesense.env".path ];
    };
  };
}
