{ inputs, ... }: {
  den.aspects.vicinae = {
    homeManager = {
      imports = [
        inputs.vicinae.homeManagerModules.default
      ];

      services.vicinae = {
        enable = true;
        systemd.enable = true;
      };
    };
  };
}
