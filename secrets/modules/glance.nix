{
  config,
  lib,
  ...
}:
let
  utils = import ../utils.nix;

  glanceUnits = [ "glance.service" ];
in
{
  systemd.services.sops-secrets.wants = glanceUnits;

  sops.secrets."glance_gh_token" = utils.mkOpts glanceUnits;

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
