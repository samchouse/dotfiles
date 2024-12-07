{
  config,
  ...
}:
let
  options = {
    restartUnits = [ "glance.service" ];
  };
in
{
  sops.secrets."glance_gh_token" = options;

  sops.templates."glance.env".content = ''
    GLANCE_GH_TOKEN=${config.sops.placeholder.glance_gh_token}
  '';

  systemd.services.glance = {
    requires = [ "sops-install-secrets.service" ];
    serviceConfig = {
      EnvironmentFile = config.sops.templates."glance.env".path;
    };
  };
}
