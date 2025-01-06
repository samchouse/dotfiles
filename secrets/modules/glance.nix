{
  config,
  lib,
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
    wantedBy = lib.mkForce [ ];
    serviceConfig = {
      EnvironmentFile = config.sops.templates."glance.env".path;
    };
  };
}
