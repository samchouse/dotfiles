{
  config,
  ...
}:
let
  options = {
    restartUnits = [ "docker-timescaledb.service" ];
  };
in
{
  sops.secrets."postgres_password" = options;

  sops.templates."postgres.env".content = ''
    POSTGRES_PASSWORD=${config.sops.placeholder.postgres_password}
  '';

  virtualisation.oci-containers.containers.timescaledb = {
    environmentFiles = [ config.sops.templates."postgres.env".path ];
  };
  systemd.services.docker-timescaledb = {
    after = [ "sops-install-secrets.service" ];
    requires = [ "sops-install-secrets.service" ];
    onSuccess = [ "sops-install-secrets.service" ];
  };
}
