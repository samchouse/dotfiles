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
  };

  outputs = { self, nixpkgs, catppuccin, home-manager, custom-fonts }: {

    nixosConfigurations.simple = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./hosts/desktop
        home-manager.nixosModules.home-manager
        {
          home-manager.backupFileExtension = "bak";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.sam.imports = [
            ./home/sam
            catppuccin.homeManagerModules.catppuccin
          ];
          home-manager.users.root.imports = [
            ./home/root
          ];

          # Optionally, use home-manager.extraSpecialArgs to pass
          # arguments to home.nix
        }
      ];
    };

    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./hosts/desktop
        home-manager.nixosModules.home-manager
        {
          home-manager.backupFileExtension = "bak";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.sam.imports = [
            ./home/sam
            catppuccin.homeManagerModules.catppuccin
          ];
          home-manager.users.root.imports = [
            ./home/root
          ];

          # Optionally, use home-manager.extraSpecialArgs to pass
          # arguments to home.nix
        }
      ];
      specialArgs = { inherit custom-fonts; };
    };

  };
}
