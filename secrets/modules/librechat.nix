{
  config,
  lib,
  ...
}:
let
  options = {
    restartUnits = [
      "meilisearch.service"
      "docker-postgres.service"
      "docker-vectordb.service"
      "docker-librechat.service"
      "docker-litellm.service"
      "docker-rag.service"
    ];
  };
in
{
  sops.secrets."meilisearch_key" = options;
  sops.secrets."openrouter_key" = options;
  sops.secrets."wolfram_app_id" = options;
  sops.secrets."postgres_password" = options;
  sops.secrets."creds_iv" = options;
  sops.secrets."creds_key" = options;
  sops.secrets."jwt_secret" = options;
  sops.secrets."jwt_refresh_secret" = options;
  sops.secrets."master_key" = options;
  sops.secrets."salt_key" = options;
  sops.secrets."anthropic_key" = options;
  sops.secrets."openai_key" = options;
  sops.secrets."litellm_key" = options;

  sops.templates."meilisearch.env".content = ''
    MEILI_MASTER_KEY=${config.sops.placeholder.meilisearch_key}
  '';
  sops.templates."postgres.env".content = ''
    POSTGRES_PASSWORD=${config.sops.placeholder.postgres_password}
  '';
  sops.templates."litellm.env".content = ''
    DATABASE_URL=postgresql://litellm:${config.sops.placeholder.postgres_password}@postgres:5432/litellm
    LITELLM_MASTER_KEY=${config.sops.placeholder.master_key}
    LITELLM_SALT_KEY=${config.sops.placeholder.salt_key}

    OPENROUTER_API_KEY=${config.sops.placeholder.openrouter_key}
    ANTHROPIC_API_KEY=${config.sops.placeholder.anthropic_key}
    OPENAI_API_KEY=${config.sops.placeholder.openai_key}
  '';
  sops.templates."librechat.env".content =
    builtins.readFile ../../hosts/desktop/config/librechat.env
    + ''
      WOLFRAM_APP_ID=${config.sops.placeholder.wolfram_app_id}
      MEILI_MASTER_KEY=${config.sops.placeholder.meilisearch_key}
      POSTGRES_PASSWORD=${config.sops.placeholder.postgres_password}
      LITELLM_API_KEY=${config.sops.placeholder.litellm_key}

      CREDS_IV=${config.sops.placeholder.creds_iv}
      CREDS_KEY=${config.sops.placeholder.creds_key}

      JWT_SECRET=${config.sops.placeholder.jwt_secret}
      JWT_REFRESH_SECRET=${config.sops.placeholder.jwt_refresh_secret}
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
    docker-postgres = {
      wantedBy = lib.mkForce [ ];
    };
    docker-litellm = {
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
    librechat = {
      environmentFiles = [ config.sops.templates."librechat.env".path ];
    };
    litellm = {
      environmentFiles = [ config.sops.templates."litellm.env".path ];
    };
    postgres = {
      environmentFiles = [ config.sops.templates."postgres.env".path ];
    };
  };
}
