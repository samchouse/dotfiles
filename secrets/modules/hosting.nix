{
  config,
  lib,
  ...
}:
let
  utils = import ../utils.nix;

  caddyUnits = [ "caddy.service" ];
  cloudflaredUnits = [ "docker-cloudflared.service" ];
in
{
  systemd.services.sops-secrets.wants = caddyUnits ++ cloudflaredUnits;

  sops.secrets."cf_api_token" = utils.mkOpts caddyUnits;
  sops.secrets."cf_tunnel_token" = utils.mkOpts cloudflaredUnits;

  sops.templates."caddy.env".content = ''
    CF_API_TOKEN=${config.sops.placeholder.cf_api_token}
  '';
  sops.templates."cloudflared.env".content = ''
    TUNNEL_TOKEN=${config.sops.placeholder.cf_tunnel_token}
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
  };
}
