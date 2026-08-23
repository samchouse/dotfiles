{ lib, ... }: {
  den.aspects.age = {
    homeManager =
      { pkgs, ... }:
      lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        xdg.configFile."sops/age/keys.txt".source = ./age-identity.txt;
      };
  };
}
