{ ... }:
{
  imports = [
    ./ai.nix
    ./glance.nix
    ./hosting.nix
    ./desktop.nix
    ./nvidia.nix
    ./tailscale.nix
    ./power.nix
    ./home-assistant.nix
    ./misc.nix
  ];

  sops.secrets."op_service_token" = { };
}
