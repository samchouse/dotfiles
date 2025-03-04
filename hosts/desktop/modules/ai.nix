{
  config,
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
        image = "ollama/ollama:0.5.12";
        ports = [ "11434:11434" ];
        autoStart = true;
        volumes = [ "ollama:/root/.ollama" ];
        extraOptions = [ "--device=nvidia.com/gpu=all" ];
        networks = [
          "litellm"
          "librechat"
        ];
      };

      librechat = {
        image = "ghcr.io/samchouse/librechat-dev:7048ca5296a73081efed8c485fdb3bebdfd67a61";
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
      vectordb = {
        image = "pgvector/pgvector:0.8.0-pg17";
        volumes = [ "vectordb:/var/lib/postgresql/data" ];
        networks = [ "librechat" ];
      };
      rag = {
        image = "ghcr.io/danny-avila/librechat-rag-api-dev:9e4bb52e15d97856e3b69653c88d2cf1bb34324f";
        volumes = [ "rag-uploads:/app/uploads" ];
        networks = [ "librechat" ];
      };

      postgres = {
        image = "postgres:17.2-alpine";
        volumes = [ "postgres:/var/lib/postgresql/data" ];
        networks = [ "litellm" ];
        environment = {
          POSTGRES_DB = "litellm";
          POSTGRES_USER = "litellm";
        };
      };
      litellm = {
        image = "ghcr.io/berriai/litellm:main-v1.61.20-nightly";
        volumes = [ "${../config/litellm.yaml}:/app/config.yaml" ];
        cmd = [ "--config=/app/config.yaml" ];
        ports = [ "4044:4000" ];
        networks = [ "litellm" ];
        environment = {
          STORE_MODEL_IN_DB = "True";
        };
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

      invokeai = {
        image = "ghcr.io/invoke-ai/invokeai:v5.7.2rc2-cuda";
        ports = [ "9090:9090" ];
        volumes = [
          "invokeai:/opt/invokeai/data"
          "${../config/invokeai.yaml}:/opt/invokeai/data/invokeai.yaml"
        ];
        extraOptions = [ "--device=nvidia.com/gpu=all" ];
      };
    };
  };
}
