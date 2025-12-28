{
  imports = [
    ./hosting.nix
  ];

  sops.secrets."op_service_token" = { };
}
