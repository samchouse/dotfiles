{
  config,
  lib,
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

  systemd.services.docker-open-webui = {
    wantedBy = lib.mkForce [ ];
  };
  virtualisation.oci-containers.containers.open-webui = {
    environmentFiles = [ config.sops.templates."open-webui.env".path ];
  };
}
