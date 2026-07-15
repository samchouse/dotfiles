{
  config,
  ...
}:
let
  util = import ../util.nix;

  pocketIdUnits = [ "pocket-id.service" ];
  cloudflaredUnits = [ "podman-cloudflared.service" ];
  filebrowserUnits = [
    "podman-eurooffice.service"
    "podman-filebrowser.service"
  ];
in
{
  systemd.services.sops-secrets.wants = filebrowserUnits ++ pocketIdUnits ++ cloudflaredUnits;

  sops.secrets."cf_tunnel_token" = util.mkOpts cloudflaredUnits;
  sops.secrets."pocketid_maxmind_key" = util.mkOpts pocketIdUnits;
  sops.secrets."pocketid_encryption_key" = util.mkOpts pocketIdUnits;

  sops.secrets."fb_oidc_client_id" = util.mkOpts filebrowserUnits;
  sops.secrets."fb_oidc_client_secret" = util.mkOpts filebrowserUnits;
  sops.secrets."eurooffice_jwt_secret" = util.mkOpts filebrowserUnits;

  sops.templates."cloudflared.env".content = ''
    TUNNEL_TOKEN=${config.sops.placeholder.cf_tunnel_token}
  '';

  sops.templates."eurooffice.env".content = ''
    JWT_SECRET=${config.sops.placeholder."eurooffice_jwt_secret"}
  '';
  sops.templates."filebrowser.env".content = ''
    FILEBROWSER_OIDC_CLIENT_ID=${config.sops.placeholder."fb_oidc_client_id"}
    FILEBROWSER_OIDC_CLIENT_SECRET=${config.sops.placeholder."fb_oidc_client_secret"}
    FILEBROWSER_ONLYOFFICE_SECRET=${config.sops.placeholder."eurooffice_jwt_secret"}
  '';
}
