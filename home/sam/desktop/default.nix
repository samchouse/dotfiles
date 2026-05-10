{
  imports = [
    ./hypr
    ./eww
    ./ags
    ./discord
    ./dunst.nix
    ./kitty.nix
    ./theme.nix
    ./vscode.nix
    ./vicinae.nix
    ./bluetooth.nix
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
