{
  config,
  lib,
  ...
}:
let
  utils = import ../utils.nix;

  litellmUnits = [ "docker-litellm.service" ];
  meilisearchUnits = [ "meilisearch.service" ];
  postgresUnits = [ "docker-postgres.service" ];
  invokeaiUnits = [ "docker-invokeai.service" ];
  librechatUnits = [
    "docker-rag.service"
    "docker-vectordb.service"
    "docker-librechat.service"
  ];

  litellmOptions = utils.mkOpts litellmUnits;
  invokeaiOptions = utils.mkOpts invokeaiUnits;
  librechatOptions = utils.mkOpts librechatUnits;
in
{
  systemd.services.sops-secrets.wants =
    meilisearchUnits ++ litellmUnits ++ postgresUnits ++ invokeaiUnits ++ librechatUnits;

  sops.secrets."salt_key" = litellmOptions;
  sops.secrets."master_key" = litellmOptions;
  sops.secrets."openai_key" = litellmOptions;
  sops.secrets."anthropic_key" = litellmOptions;
  sops.secrets."openrouter_key" = litellmOptions;
  sops.secrets."creds_iv" = librechatOptions;
  sops.secrets."creds_key" = librechatOptions;
  sops.secrets."jwt_secret" = librechatOptions;
  sops.secrets."litellm_key" = librechatOptions;
  sops.secrets."tracker_key" = librechatOptions;
  sops.secrets."jwt_refresh_secret" = librechatOptions;
  sops.secrets."civitai_token" = invokeaiOptions;
  sops.secrets."huggingface_token" = invokeaiOptions;
  sops.secrets."meilisearch_key" = utils.mkOpts (meilisearchUnits ++ librechatUnits);
  sops.secrets."postgres_password" = utils.mkOpts (postgresUnits ++ librechatUnits ++ litellmUnits);

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
      WOLFRAM_APP_ID=${config.sops.placeholder.tracker_key}
      TAVILY_API_KEY=${config.sops.placeholder.tracker_key}
      YOUTUBE_API_KEY=${config.sops.placeholder.tracker_key}
      OPENWEATHER_API_KEY=${config.sops.placeholder.tracker_key}
      MEILI_MASTER_KEY=${config.sops.placeholder.meilisearch_key}
      POSTGRES_PASSWORD=${config.sops.placeholder.postgres_password}
      LITELLM_API_KEY=${config.sops.placeholder.litellm_key}

      CREDS_IV=${config.sops.placeholder.creds_iv}
      CREDS_KEY=${config.sops.placeholder.creds_key}

      JWT_SECRET=${config.sops.placeholder.jwt_secret}
      JWT_REFRESH_SECRET=${config.sops.placeholder.jwt_refresh_secret}
    '';
  sops.templates."invokeai.env".content = ''
    INVOKEAI_ROOT=/opt/invokeai/data
    INVOKEAI_REMOTE_API_TOKENS=[{"url_regex": "huggingface.co", "token": "${config.sops.placeholder.huggingface_token}"}, {"url_regex": "civitai.com", "token": "${config.sops.placeholder.civitai_token}"}]
  '';

  systemd.services = {
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
    invokeai = {
      environmentFiles = [ config.sops.templates."invokeai.env".path ];
    };
  };
}
