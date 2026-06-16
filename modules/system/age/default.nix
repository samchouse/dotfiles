{ lib, ... }: {
  den.aspects.age = {
    homeManager =
      { pkgs, ... }:
      lib.mkIf pkgs.stdenv.isLinux {
        xdg.configFile."sops/age/keys.txt".source = ./age-identity.txt;
      };
  };
}
