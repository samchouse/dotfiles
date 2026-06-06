{ config, ... }:
{
  imports = [
    ./hosting.nix
  ];

  sops.secrets."op_service_token" = { };
  sops.secrets."arccodex_api_key" = {
    owner = config.users.users.sam.name;
    group = config.users.users.sam.group;
  };
}
