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
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2-0.20250420134112-006ebb07b349" ];
      hash = "sha256-2U+icm4GtI5Fww6U8nKzQ/+pPf63T3scTGuj1zjj4b4=";
    };

    email = "sam@chouse.dev";
    virtualHosts = builtins.listToAttrs (
      map
        (host: {
          name = host.domain;
          value = {
            extraConfig = ''
              tls {
                dns cloudflare ${if host ? cloudflare then host.cloudflare else "{env.CF_API_TOKEN}"} 
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
          {
            domain = "crm.coalesc.xyz";
            port = 3625;
            cloudflare = "{env.COALESC_CF_API_TOKEN}";
          }
        ]
    );
  };

  virtualisation.oci-containers = {
    containers = {
      cloudflared = {
        image = "cloudflare/cloudflared:2025.4.0";
        autoStart = false;
        cmd = [
          "tunnel"
          "--no-autoupdate"
          "run"
        ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
      };
      cloudflared-coalesc = {
        image = "cloudflare/cloudflared:2025.4.0";
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
