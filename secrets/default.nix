{ ... }:
{
  imports = [
    ./caddy.nix
    ./glance.nix
    ./open-webui.nix
  ];

  sops.secrets."op_service_token" = { };
}
