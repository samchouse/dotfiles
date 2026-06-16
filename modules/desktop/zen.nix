{ lib, ... }: {
  den.aspects.zen = {
    homeManager =
      { host, ... }:
      lib.optionalAttrs (host.class == "nixos") {

        xdg.mimeApps = {
          enable = false;

          associations.added = {
            "application/pdf" = "zen-beta.desktop";
          };

          defaultApplications = {
            "application/pdf" = [ "zen-beta.desktop" ];
          };
        };
      };

    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ zen-browser ];
    };

    darwin = {
      homebrew.casks = "zen";
    };
  };
}
