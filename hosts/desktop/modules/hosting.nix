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
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2-0.20250506153119-35fb8474f57d" ];
      hash = "sha256-p9YUXUBHrmfKqALUtuKct+vie8HqJ2rTiBnjrsU7twg=";
    };

    email = "sam@chouse.dev";
    virtualHosts = {
      "http://dev.coalesc.xyz" = {
        extraConfig = ''
          @userpath path_regexp userpath ^/([^/]+)(?:(/.*)|/?)?$
          handle @userpath {
            rewrite * {re.userpath.2}
            reverse_proxy dev-{re.userpath.1}.coalesc.xyz:443 {
              transport http { tls }
              header_up Host dev-{re.userpath.1}.coalesc.xyz
            }
          }
        '';
      };
    }
    // builtins.listToAttrs (
      map
        (host: {
          name = host.domain;
          value = {
            extraConfig = ''
              tls {
                dns cloudflare ${if host ? cloudflare then host.cloudflare else "{env.CF_API_TOKEN}"} 
              }
              reverse_proxy ${if host ? host then host.host else ""}:${toString host.port} {
                header_up X-Forwarded-For {header.CF-Connecting-IP}
                ${if host ? extra then host.extra else ""}
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
            domain = "deploy.xenfo.dev";
            port = 3000;
            host = "pi";
          }
          {
            domain = "crm.coalesc.xyz";
            port = 3625;
            cloudflare = "{env.COALESC_CF_API_TOKEN}";
          }
          {
            domain = "ts.coalesc.xyz";
            port = 8108;
            cloudflare = "{env.COALESC_CF_API_TOKEN}";
          }
          {
            domain = "preview.coalesc.xyz";
            port = 443;
            host = "https://staging1";
            cloudflare = "{env.COALESC_CF_API_TOKEN}";
            extra = ''
              header_up Host preview.coalesc.xyz
              header_up Origin https://preview.coalesc.xyz

              transport http {
                tls_server_name preview.coalesc.xyz
              }
            '';
          }
        ]
    );
  };

  virtualisation.oci-containers = {
    containers = {
      cloudflared = {
        image = "cloudflare/cloudflared:2025.10.1";
        autoStart = false;
        cmd = [
          "tunnel"
          "--no-autoupdate"
          "run"
        ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
      };
      cloudflared-coalesc = {
        image = "cloudflare/cloudflared:2025.10.1";
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
