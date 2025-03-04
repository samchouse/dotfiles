{
  config,
  lib,
  ...
}:
let
  options = {
    restartUnits = [ "caddy.service" ];
  };
in
{
  sops.secrets."cf_api_token" = options;
  sops.secrets."cf_tunnel_token" = options;

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
    docker-cloudflared = {
      wantedBy = lib.mkForce [ ];
    };
  };
  virtualisation.oci-containers.containers = {
    cloudflared = {
      environmentFiles = [ config.sops.templates."cloudflared.env".path ];
    };
  };
}
