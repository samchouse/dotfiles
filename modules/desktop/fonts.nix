{ inputs, ... }: {
  flake-file.inputs.custom-fonts = {
    url = "git+ssh://git@github.com/samchouse/fonts.git?ref=main";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.fonts = {
    nixos = { pkgs, ... }: {
      fonts.packages = with pkgs; [
        material-symbols
        (lib.mkIf (
          inputs ? custom-fonts
        ) inputs.custom-fonts.packages.${stdenv.hostPlatform.system}.default)
      ];
    };
  };
}
