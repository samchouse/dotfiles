{
  description = "Sam's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    custom-fonts.url = "git+ssh://git@github.com/samchouse/fonts.git?ref=main";
    niqspkgs.url = "github:diniamo/niqspkgs";
    sops-nix.url = "github:samchouse/sops-nix";
    age-plugin-op = {
      url = "github:samchouse/age-plugin-op";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      catppuccin,
      home-manager,
      custom-fonts,
      niqspkgs,
      sops-nix,
      age-plugin-op
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

      nixosConfigurations.simple = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/desktop
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "bak";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sam.imports = [
              ./home/sam
              catppuccin.homeManagerModules.catppuccin
            ];
            home-manager.users.root.imports = [ ./home/root ];
            home-manager.extraSpecialArgs = {
              inherit niqspkgs;
            };
          }
        ];
        specialArgs = {
          inherit age-plugin-op;
        };
      };

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/desktop
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "bak";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sam.imports = [
              ./home/sam
              catppuccin.homeManagerModules.catppuccin
            ];
            home-manager.users.root.imports = [ ./home/root ];
            home-manager.extraSpecialArgs = {
              inherit niqspkgs;
            };
          }
        ];
        specialArgs = {
          inherit custom-fonts;
          inherit age-plugin-op;
        };
      };
    };
}
