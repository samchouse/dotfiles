{
  config,
  ...
}:
{
  sops.secrets."postgres_password" = { };

  sops.templates."postgres.env".content = ''
    POSTGRES_PASSWORD=${config.sops.placeholder.postgres_password}
  '';

  virtualisation.oci-containers.containers.timescaledb = {
    environmentFiles = [ config.sops.templates."postgres.env".path ];
  };
}
