{
  pkgs,
  ...
}:
{
  hardware.nvidia-container-toolkit.enable = true;
  environment.systemPackages = with pkgs; [ ffmpeg ];

  services = {
    meilisearch = {
      enable = true;
      listenAddress = "0.0.0.0";
    };
    mongodb = {
      enable = true;
      package = pkgs.mongodb-ce;
      bind_ip = "0.0.0.0";
    };
  };

  virtualisation.oci-containers = {
    containers = {
      ollama = {
        image = "ollama/ollama:0.6.4";
        ports = [ "11434:11434" ];
        volumes = [ "ollama:/root/.ollama" ];
        extraOptions = [ "--device=nvidia.com/gpu=all" ];
        networks = [
          "litellm"
          "librechat"
        ];
      };

      librechat = {
        image = "ghcr.io/samchouse/librechat-dev:57fad4efb1bf2cdb6d6b02389190f6f71bab3f83";
        autoStart = false;
        ports = [ "3080:3080" ];
        volumes = [
          "${../config/librechat.yaml}:/app/librechat.yaml"
          "librechat-images:/app/client/public/images"
        ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
        networks = [
          "librechat"
          "litellm"
        ];
      };
      rag = {
        image = "ghcr.io/danny-avila/librechat-rag-api-dev:v0.4.0";
        autoStart = false;
        volumes = [ "rag-uploads:/app/uploads" ];
        networks = [ "librechat" ];
      };
      vectordb = {
        image = "pgvector/pgvector:0.8.0-pg17";
        autoStart = false;
        volumes = [ "vectordb:/var/lib/postgresql/data" ];
        networks = [ "librechat" ];
      };

      postgres = {
        image = "postgres:17.4-alpine";
        autoStart = false;
        volumes = [ "postgres:/var/lib/postgresql/data" ];
        networks = [ "litellm" ];
        environment = {
          POSTGRES_DB = "litellm";
          POSTGRES_USER = "litellm";
        };
      };
      litellm = {
        image = "ghcr.io/berriai/litellm:main-v1.65.4-nightly";
        autoStart = false;
        volumes = [ "${../config/litellm.yaml}:/app/config.yaml" ];
        cmd = [ "--config=/app/config.yaml" ];
        ports = [ "4044:4000" ];
        networks = [ "litellm" ];
        environment = {
          STORE_MODEL_IN_DB = "True";
        };
      };

      invokeai = {
        image = "ghcr.io/invoke-ai/invokeai:v5.9.1-cuda";
        autoStart = false;
        ports = [ "9090:9090" ];
        volumes = [
          "invokeai:/opt/invokeai/data"
          "${../config/invokeai.yaml}:/opt/invokeai/data/invokeai.yaml"
        ];
        extraOptions = [ "--device=nvidia.com/gpu=all" ];
      };

      speaches = {
        image = "ghcr.io/speaches-ai/speaches:0.7.0-cuda";
        extraOptions = [ "--device=nvidia.com/gpu=all" ];
        networks = [ "librechat" ];
      };
      kokoro-fastapi = {
        image = "ghcr.io/remsky/kokoro-fastapi-gpu:v0.2.2";
        extraOptions = [ "--device=nvidia.com/gpu=all" ];
        networks = [ "librechat" ];
      };
    };
  };
}
