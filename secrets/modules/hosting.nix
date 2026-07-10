{
  config,
  ...
}:
let
  util = import ../util.nix;

  pocketIdUnits = [ "pocket-id.service" ];
  copypartyUnits = [ "copyparty.service" ];
  cloudflaredUnits = [ "podman-cloudflared.service" ];
in
{
  systemd.services.sops-secrets.wants = copypartyUnits ++ pocketIdUnits ++ cloudflaredUnits;

  sops.secrets."cf_tunnel_token" = util.mkOpts cloudflaredUnits;
  sops.secrets."pocketid_maxmind_key" = util.mkOpts pocketIdUnits;
  sops.secrets."pocketid_encryption_key" = util.mkOpts pocketIdUnits;
  sops.secrets."copyparty_password" = {
    owner = "sam";
    group = "users";
  }
  // util.mkOpts copypartyUnits;

  sops.templates."cloudflared.env".content = ''
    TUNNEL_TOKEN=${config.sops.placeholder.cf_tunnel_token}
  '';

  virtualisation.oci-containers.containers = {
    cloudflared = {
      environmentFiles = [ config.sops.templates."cloudflared.env".path ];
    };
  };
}
