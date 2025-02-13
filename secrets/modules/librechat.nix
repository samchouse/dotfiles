{
  config,
  lib,
  ...
}:
let
  options = {
    restartUnits = [ "meilisearch.service" ];
  };
in
{
  sops.secrets."meilisearch_key" = options;

  sops.templates."meilisearch.env".content = ''
    MEILI_MASTER_KEY=${config.sops.placeholder.librechat.meilisearch_key}
  '';
  sops.templates."librechat.env".content =
    builtins.readFile ../../hosts/desktop/config/librechat.env
    + ''
      OPENROUTER_KEY=${config.sops.placeholder.librechat.openrouter_key}
      WOLFRAM_APP_ID=${config.sops.placeholder.librechat.wolfram_app_id}
      MEILI_MASTER_KEY=${config.sops.placeholder.librechat.meilisearch_key}
      POSTGRES_PASSWORD=${config.sops.placeholder.librechat.postgres_password}

      CREDS_IV=${config.sops.placeholder.librechat.creds.iv}
      CREDS_KEY=${config.sops.placeholder.librechat.creds.key}

      JWT_SECRET=${config.sops.placeholder.librechat.jwt.secret}
      JWT_REFRESH_SECRET=${config.sops.placeholder.librechat.jwt.refresh_secret}
    '';

  systemd.services = {
    docker-librechat = {
      wantedBy = lib.mkForce [ ];
    };
    docker-rag = {
      wantedBy = lib.mkForce [ ];
    };
    docker-vectordb = {
      wantedBy = lib.mkForce [ ];
    };
    meilisearch = {
      wantedBy = lib.mkForce [ ];
      serviceConfig = {
        EnvironmentFile = config.sops.templates."meilisearch.env".path;
      };
    };
  };
  virtualisation.oci-containers.containers = {
    vectordb = {
      environmentFiles = [ config.sops.templates."librechat.env".path ];
    };
    rag = {
      environmentFiles = [ config.sops.templates."librechat.env".path ];
    };
  };
}
