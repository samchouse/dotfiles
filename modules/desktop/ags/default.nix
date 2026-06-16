{ lib, inputs, ... }: {
  den.aspects.ags = {
    homeManager =
      { pkgs, host, ... }:
      lib.optionalAttrs (host.class == "nixos") {
        imports = [
          inputs.ags.homeManagerModules.default
        ];

        programs.ags = {
          enable = true;
          extraPackages = with pkgs.astal; [
            tray
            mpris
            notifd
            network
            hyprland
            bluetooth
            wireplumber
          ];

          configDir = ./.;
        };
      };
  };
}
