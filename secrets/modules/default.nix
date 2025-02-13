{ ... }:
{
  imports = [
    ./caddy.nix
    ./glance.nix
    ./open-webui.nix
    ./librechat.nix
  ];

  sops.secrets."op_service_token" = { };

  systemd.services.sops-secrets.wants = [
    "docker-open-webui.service"
    "glance.service"
    "caddy.service"
  ];
}
