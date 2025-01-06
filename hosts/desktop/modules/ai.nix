{
  config,
  pkgs,
  ...
}:
{
  hardware.nvidia-container-toolkit.enable = true;
  environment.systemPackages = with pkgs; [ ffmpeg ];

  services = {
    tika = {
      enable = true;
      enableOcr = true;
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
        image = "ollama/ollama:0.5.4";
        ports = [ "11434:11434" ];
        autoStart = true;
        volumes = [ "ollama:/root/.ollama" ];
        extraOptions = [ "--device=nvidia.com/gpu=all" ];
      };

      open-webui = {
        image = "ghcr.io/open-webui/open-webui:0.5.3-cuda";
        ports = [ "8080:8080" ];
        volumes = [ "open-webui:/app/backend/data" ];
        extraOptions = [
          "--device=nvidia.com/gpu=all"
          "--add-host=host.docker.internal:host-gateway"
          "--security-opt=seccomp=unconfined"
          "--mount=type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup,readonly=false"
          "--security-opt=apparmor=unconfined"
          "--security-opt=label=type:container_engine_t"
        ];
        environment = {
          USE_CUDA_DOCKER = "true";
        };
      };
      open-webui-pipelines = {
        image = "ghcr.io/open-webui/pipelines:git-1367d95";
        ports = [ "9099:9099" ];
        volumes = [ "pipelines:/app/pipelines" ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
      };

      openedai-speech = {
        image = "ghcr.io/matatonic/openedai-speech:0.18.2";
        ports = [ "8013:8000" ];
        extraOptions = [
          "--device=nvidia.com/gpu=all"
          "--add-host=host.docker.internal:host-gateway"
        ];
      };
    };
  };
}
