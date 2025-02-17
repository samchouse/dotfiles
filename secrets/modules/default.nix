{ ... }:
{
  imports = [
    ./caddy.nix
    ./glance.nix
    ./librechat.nix
  ];

  sops.secrets."op_service_token" = { };

  systemd.services.sops-secrets.wants = [
    "caddy.service"
    "glance.service"
    "docker-rag.service"
    "docker-librechat.service"
    "docker-postgres.service"
    "docker-vectordb.service"
    "docker-litellm.service"
  ];
}
