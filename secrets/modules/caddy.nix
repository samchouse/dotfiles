{
  config,
  ...
}:
let
  options = {
    restartUnits = [ "caddy.service" ];
  };
in
{
  sops.secrets."cf_api_token" = options;

  sops.templates."caddy.env".content = ''
    CF_API_TOKEN=${config.sops.placeholder.cf_api_token}
  '';

  systemd.services.caddy = {
    after = [ "sops-install-secrets.service" ];
    requires = [ "sops-install-secrets.service" ];
    onSuccess = [ "sops-install-secrets.service" ];
    serviceConfig = {
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      EnvironmentFile = config.sops.templates."caddy.env".path;
    };
  };
}
