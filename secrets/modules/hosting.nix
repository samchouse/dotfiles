{
  config,
  lib,
  ...
}:
let
  utils = import ../utils.nix;

  caddyUnits = [ "caddy.service" ];
  cloudflaredUnits = [ "podman-cloudflared.service" ];
  coalescCloudflaredUnits = [ "podman-cloudflared-coalesc.service" ];

  caddyOptions = utils.mkOpts caddyUnits;
in
{
  systemd.services.sops-secrets.wants = caddyUnits ++ cloudflaredUnits ++ coalescCloudflaredUnits;

  sops.secrets."cf_api_token" = caddyOptions;
  sops.secrets."coalesc_cf_api_token" = caddyOptions;
  sops.secrets."cf_tunnel_token" = utils.mkOpts cloudflaredUnits;
  sops.secrets."coalesc_cf_tunnel_token" = utils.mkOpts coalescCloudflaredUnits;

  sops.templates."caddy.env".content = ''
    CF_API_TOKEN=${config.sops.placeholder.cf_api_token}
    COALESC_CF_API_TOKEN=${config.sops.placeholder.coalesc_cf_api_token}
  '';
  sops.templates."cloudflared.env".content = ''
    TUNNEL_TOKEN=${config.sops.placeholder.cf_tunnel_token}
  '';
  sops.templates."coalesc-cloudflared.env".content = ''
    TUNNEL_TOKEN=${config.sops.placeholder.coalesc_cf_tunnel_token}
  '';

  systemd.services = {
    caddy = {
      wantedBy = lib.mkForce [ ];
      serviceConfig = {
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        EnvironmentFile = config.sops.templates."caddy.env".path;
      };
    };
  };
  virtualisation.oci-containers.containers = {
    cloudflared = {
      environmentFiles = [ config.sops.templates."cloudflared.env".path ];
    };
    cloudflared-coalesc = {
      environmentFiles = [ config.sops.templates."coalesc-cloudflared.env".path ];
    };
  };
}
