{
  config,
  ...
}:
let
  options = {
    restartUnits = [ "open-webui.service" ];
  };
in
{
  sops.secrets."open_api_key" = options;

  sops.templates."open-webui.env".content = ''
    env=PROD

    OPEN_API_KEY=${config.sops.placeholder.open_api_key}
  '';

  systemd.services.open-webui = {
    after = [ "sops-install-secrets.service" ];
    requires = [ "sops-install-secrets.service" ];
    onSuccess = [ "sops-install-secrets.service" ];
  };
}
