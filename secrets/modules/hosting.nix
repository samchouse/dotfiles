{
  config,
  ...
}:
let
  utils = import ../utils.nix;

  cloudflaredUnits = [ "podman-cloudflared.service" ];
in
{
  systemd.services.sops-secrets.wants = cloudflaredUnits;

  sops.secrets."cf_tunnel_token" = utils.mkOpts cloudflaredUnits;

  sops.templates."cloudflared.env".content = ''
    TUNNEL_TOKEN=${config.sops.placeholder.cf_tunnel_token}
  '';

  virtualisation.oci-containers.containers = {
    cloudflared = {
      environmentFiles = [ config.sops.templates."cloudflared.env".path ];
    };
  };
}
