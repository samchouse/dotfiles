{ ... }:
{
  imports = [
    ./caddy.nix
    ./glance.nix
    ./postgres.nix
    ./open-webui.nix
  ];

  sops.secrets."op_service_token" = { };
}
