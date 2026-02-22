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
      hash = "sha256-TiG1bEGCxMANYsm7/G+E365fXkeVtfJEhgO54uP+tTI=";
    };

    email = "sam@chouse.dev";
    globalConfig = ''
      dns cloudflare {env.CF_API_TOKEN}
    '';
    virtualHosts = builtins.listToAttrs (
      map
        (host: {
          name = host.domain;
          value = {
            extraConfig = ''
              reverse_proxy ${if host ? hostname then host.hostname else ""}:${toString host.port} {
                header_up X-Forwarded-For {header.CF-Connecting-IP}
              }
            '';
          };
        })
        [
          {
            domain = "ha.xenfo.dev";
            port = 8123;
          }
          {
            domain = "sys.xenfo.dev";
            port = 7463;
          }
          {
            domain = "deploy.xenfo.dev";
            hostname = "pi";
            port = 3000;
          }
        ]
    );
  };

  virtualisation.oci-containers.containers = {
    cloudflared = {
      image = "cloudflare/cloudflared:2026.2.0";
      autoStart = false;
      cmd = [
        "tunnel"
        "--no-autoupdate"
        "run"
      ];
    };
  };
}
