{
  den.aspects.nh = {
    nixos =
      let
        flake = "/home/sam/Documents/projects/personal/dotfiles";
      in
      {
        programs.nh = {
          enable = true;
          inherit flake;

          clean = {
            enable = true;
            extraArgs = "--keep-since 4d --keep 3";
          };
        };

        environment.sessionVariables.NH_FLAKE = flake;
      };

    darwin = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.nh ];
      environment.variables.NH_FLAKE = "/Users/sam/Documents/Projects/personal/dotfiles";
    };
  };
}
