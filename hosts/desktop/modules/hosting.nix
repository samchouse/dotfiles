{
  pkgs,
  ...
}:
{
  boot.kernel.sysctl."net.core.rmem_max" = 7500000;
  boot.kernel.sysctl."net.core.wmem_max" = 7500000;

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.0.0-20250228175314-1fb64108d4de" ];
      hash = "sha256-YYpsf8HMONR1teMiSymo2y+HrKoxuJMKIea5/NEykGc=";
    };

    email = "sam@chouse.dev";
    virtualHosts = builtins.listToAttrs (
      map
        (host: {
          name = host.domain;
          value = {
            extraConfig = ''
              tls {
                dns cloudflare {env.CF_API_TOKEN}
              }
              reverse_proxy :${toString host.port} {
                header_up X-Forwarded-For {header.CF-Connecting-IP}
              }
            '';
          };
        })
        [
          {
            domain = "ai.xenfo.dev";
            port = 3080;
          }
          {
            domain = "ha.xenfo.dev";
            port = 8123;
          }
          {
            domain = "home.xenfo.dev";
            port = 8090;
          }
          {
            domain = "invoke.xenfo.dev";
            port = 9090;
          }
          {
            domain = "lllm.xenfo.dev";
            port = 4044;
          }
          {
            domain = "tracker.xenfo.dev";
            port = 3729;
          }
          {
            domain = "sys.xenfo.dev";
            port = 7463;
          }
        ]
    );
  };

  virtualisation.oci-containers = {
    containers = {
      cloudflared = {
        image = "cloudflare/cloudflared:2025.2.1";
        autoStart = false;
        cmd = [
          "tunnel"
          "--no-autoupdate"
          "run"
        ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
      };
    };
  };
}
