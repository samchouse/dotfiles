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
    tika = {
      enable = true;
      enableOcr = true;

      listenAddress = "0.0.0.0";
    };
    searx = {
      enable = true;
      package = pkgs.searxng;
      redisCreateLocally = true;
      settings = {
        use_default_settings = true;

        server = {
          secret_key = "super-secret-key";
          limiter = false;
          image_proxy = true;
          port = 8888;
          bind_address = "0.0.0.0";
        };

        ui = {
          static_use_hash = true;
        };

        search = {
          safe_search = 0;
          autocomplete = "";
          default_lang = "";
          formats = [
            "html"
            "json"
          ];
        };
      };
      limiterSettings.botdetection.ip_limit.link_token = true;
    };
  };

  virtualisation.oci-containers = {
    containers = {
      ollama = {
        image = "ollama/ollama:0.5.7";
        ports = [ "11434:11434" ];
        autoStart = true;
        volumes = [ "ollama:/root/.ollama" ];
        extraOptions = [ "--device=nvidia.com/gpu=all" ];
      };

      open-webui = {
        image = "ghcr.io/open-webui/open-webui:0.5.10";
        ports = [ "8080:8080" ];
        volumes = [ "open-webui:/app/backend/data" ];
        extraOptions = [
          "--add-host=host.docker.internal:host-gateway"
          "--security-opt=seccomp=unconfined"
          "--mount=type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup,readonly=false"
          "--security-opt=apparmor=unconfined"
          "--security-opt=label=type:container_engine_t"
        ];
      };
      open-webui-pipelines = {
        image = "ghcr.io/open-webui/pipelines:git-db29eb2";
        ports = [ "9099:9099" ];
        volumes = [ "pipelines:/app/pipelines" ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
      };

      librechat = {
        image = "ghcr.io/danny-avila/librechat:v0.7.7-rc1";
        ports = [ "3080:3080" ];
        volumes = [ "${../config/librechat.env}:/app/.env" ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
      };
      vectordb = {
        image = "pgvector/pgvector:0.8.0-pg17";
        ports = [ "5432:5432" ];
        volumes = [ "vectordb:/var/lib/postgresql/data" ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
      };
      rag = {
        image = "ghcr.io/danny-avila/librechat-rag-api-dev:9e4bb52e15d97856e3b69653c88d2cf1bb34324f";
        ports = [ "6549:6549" ];
        volumes = [ "rag-uploads:/app/uploads" ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
      };
    };
  };
}
