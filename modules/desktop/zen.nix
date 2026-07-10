{ lib, inputs, ... }: {
  flake-file.inputs.zen-browser = {
    url = "github:0xc000022070/zen-browser-flake/beta";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
    };
  };

  den.aspects.zen = {
    homeManager =
      { host, ... }:
      lib.optionalAttrs (host.class == "nixos") {

        xdg.mimeApps = {
          enable = false;

          associations.added = {
            "application/pdf" = "zen-beta.desktop";
          };

          defaultApplications = {
            "application/pdf" = [ "zen-beta.desktop" ];
          };
        };
      };

    nixos = { host, ... }: {
      environment.systemPackages = [ inputs.zen-browser.packages.${host.system}.default ];
    };

    darwin = {
      homebrew.casks = [ "zen" ];
    };
  };
}
