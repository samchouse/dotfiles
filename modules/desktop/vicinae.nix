{ inputs, ... }: {
  flake-file.inputs.vicinae.url = "github:vicinaehq/vicinae";

  den.aspects.vicinae = {
    homeManager = {
      imports = [
        inputs.vicinae.homeManagerModules.default
      ];

      programs.vicinae = {
        enable = true;
        systemd.enable = true;
      };
    };

    nixos = { host, ... }: {
      nixpkgs.overlays = [ (_: _: { vicinae = inputs.vicinae.packages.${host.system}.default; }) ];
    };
  };
}
