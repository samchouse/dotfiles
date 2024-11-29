{ pkgs, age-plugin-op, ... }:
{
  imports = [
    ./modules
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.keyFile = "/home/sam/.config/sops/age/keys.txt";
  sops.environment = {
    PATH = "/run/wrappers/bin:/run/current-system/sw/bin";
  };

  environment.systemPackages =
    with pkgs;
    [
      age
      (sops.overrideAttrs (oldAttrs: rec {
        version = "git";
        src = fetchFromGitHub {
          owner = "samchouse";
          repo = "sops";
          rev = "21878be7fdbc13617ae48f3b63952c10df624d8b";
          hash = "sha256-nAULMxP6IPNyYn4UhhX6X+8nzYwOcPPgLv0RuXOp1WY=";
        };
        vendorHash = "sha256-NS0b25NQEJle///iRHAG3uTC5p6rlGSyHVwEESki3p4=";
      }))
    ]
    ++ [ age-plugin-op.defaultPackage."x86_64-linux" ];
}
