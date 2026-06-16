{ inputs, ... }: {
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
