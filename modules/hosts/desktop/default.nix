{
  den,
  inputs,
  ...
}:
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.hosts.x86_64-linux.desktop.users = {
    sam = { };
    root = { };
  };

  den.aspects.desktop = {
    includes = [
      den.aspects.beszel
      den.aspects.openrgb
      den.aspects.hardware
      den.aspects.hyprland
      den.aspects.services
      den.aspects.copyparty
      den.aspects.networking
      den.aspects.desktopPackages
    ];

    nixos = {
      imports = [
        ../../../secrets
        inputs.sops-nix.nixosModules.sops
      ];
    };
  };
}
