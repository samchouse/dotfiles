{ den, inputs, ... }: {
  flake-file.inputs.niqspkgs = {
    url = "github:diniamo/niqspkgs";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.hyprland = {
    includes = [
      den.aspects.theme
      den.aspects.dunst
      den.aspects.vicinae
      den.aspects.sunshine
      den.aspects.security
    ];

    nixos = { host, ... }: {
      programs.hyprland.enable = true;
      xdg.portal.xdgOpenUsePortal = true;
      security.pam.services.hyprlock = { };
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      nixpkgs.overlays = [
        (_: _: {
          niqs = inputs.niqspkgs.packages.${host.system};
        })
      ];
    };

    homeManager = { pkgs, ... }: {
      xdg.configFile."hypr/scripts" = {
        source = ./scripts;
        recursive = true;
      };

      home = {
        sessionVariables.QT_QPA_PLATFORM = "wayland";

        pointerCursor = {
          enable = true;
          gtk.enable = false;
          x11.enable = true;
          package = pkgs.niqs.bibata-hyprcursor;
          name = "Bibata-modern";
          size = 24;
        };
      };

      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;

        configType = "lua";
        extraConfig = builtins.readFile ./land.lua;
      };
    };
  };
}
