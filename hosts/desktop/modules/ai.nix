{
  config,
  pkgs,
  ...
}:
{
  hardware.nvidia-container-toolkit.enable = true;
  environment.systemPackages = with pkgs; [ ffmpeg ];

  services = {
    open-webui = {
      enable = true;
      package = pkgs.small.open-webui;

      host = "0.0.0.0";
      environmentFile = config.sops.templates."open-webui.env".path;
    };

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

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "0.0.0.0";
          http_port = 3012;
          domain = "localhost";
        };
        users = {
          allow_sign_up = false;
        };
        "auth.proxy" = {
          enabled = true;
        };
        "unified_alerting" = {
          enabled = false;
        };
      };
    };
  };

  virtualisation.oci-containers = {
    containers = {
      ollama = {
        image = "ollama/ollama:0.4.3";
        ports = [ "11434:11434" ];
        autoStart = true;
        volumes = [ "ollama:/root/.ollama" ];
        extraOptions = [ "--device=nvidia.com/gpu=all" ];
      };
      open-webui-pipelines = {
        image = "ghcr.io/open-webui/pipelines:git-1367d95";
        ports = [ "9099:9099" ];
        autoStart = true;
        volumes = [ "pipelines:/app/pipelines" ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
      };

      timescaledb = {
        image = "timescale/timescaledb:2.17.2-pg16";
        ports = [ "5432:5432" ];
        volumes = [
          "timescaledb:/home/postgres/pgdata/data"
        ];
        environment.POSTGRES_DB = "open-webui";
      };
    };
  };
}
