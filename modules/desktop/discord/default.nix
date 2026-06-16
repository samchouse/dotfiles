{ lib, ... }: {
  den.aspects.discord = {
    homeManager =
      {
        host,
        pkgs,
        ...
      }:
      lib.optionalAttrs (host.class == "nixos") {
        home.packages = with pkgs; [
          (discord-canary.override {
            withVencord = true;
            vencord = pkgs.vencord.overrideAttrs (old: {
              patches = old.patches ++ [ ./plugins/waylandFix.patch ];
            });
          })
        ];
      };

    darwin = {
      homebrew.casks = [ "discord" ];
    };
  };
}
