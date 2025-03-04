{ ... }:
{
  imports = [
    ./ai.nix
    ./glance.nix
    ./hosting.nix
  ];

  sops.secrets."op_service_token" = { };

  systemd.services.sops-secrets.wants = [
    "caddy.service"
    "glance.service"
    "docker-rag.service"
    "docker-invokeai.service"
    "docker-librechat.service"
    "docker-postgres.service"
    "docker-vectordb.service"
    "docker-litellm.service"
    "docker-cloudflared.service"
  ];
}
