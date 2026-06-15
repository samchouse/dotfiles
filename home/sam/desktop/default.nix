{
  imports = [
    ./ags
    ./discord
    ./dunst.nix
    ./kitty.nix
    ./theme.nix
    ./vicinae.nix
  ];

  xdg.mimeApps = {
    enable = false;

    associations.added = {
      "application/pdf" = "zen-beta.desktop";
    };

    defaultApplications = {
      "application/pdf" = [ "zen-beta.desktop" ];
    };
  };
}
