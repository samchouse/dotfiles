{
  config,
  pkgs,
  caddy-nixos,
  ...
}:
let
  tlsConf = ''
    tls {
      dns cloudflare {env.CF_API_TOKEN}
    }
  '';
in
{
  boot.kernel.sysctl."net.core.rmem_max" = 7500000;
  boot.kernel.sysctl."net.core.wmem_max" = 7500000;

  services.caddy = {
    enable = true;
    package = caddy-nixos.packages.x86_64-linux.caddy;

    email = "sam@chouse.dev";
    virtualHosts = {
      "ai.xenfo.dev" = {
        extraConfig = ''
          ${tlsConf}
          reverse_proxy :8080
        '';
      };
      "home.xenfo.dev" = {
        extraConfig = ''
          ${tlsConf}
          reverse_proxy :8090
        '';
      };
      "ha.xenfo.dev" = {
        extraConfig = ''
          ${tlsConf}
          reverse_proxy :8123 {
            header_up X-Forwarded-For {header.CF-Connecting-IP}
          }
        '';
      };
    };
  };

  services.cloudflared = {
    enable = true;

    user = "sam";
    tunnels = {
      "f9331601-f962-4b2a-9bbf-0d140f17afbe" = {
        default = "http_status:404";
        credentialsFile = "/home/sam/.cloudflared/f9331601-f962-4b2a-9bbf-0d140f17afbe.json";
        ingress = {
          "ai.xenfo.dev" = {
            service = "https://localhost";
            originRequest = {
              originServerName = "ai.xenfo.dev";
              httpHostHeader = "ai.xenfo.dev";
            };
          };
          "home.xenfo.dev" = {
            service = "https://localhost";
            originRequest = {
              originServerName = "home.xenfo.dev";
              httpHostHeader = "home.xenfo.dev";
            };
          };
          "ha.xenfo.dev" = {
            service = "https://localhost";
            originRequest = {
              originServerName = "ha.xenfo.dev";
              httpHostHeader = "ha.xenfo.dev";
            };
          };
        };
      };
    };
  };
}
