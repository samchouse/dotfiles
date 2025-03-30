{
  imports = [
    ./hypr
    ./rofi
    ./eww
    ./discord
    ./dunst.nix
    ./kitty.nix
    ./vscode.nix
    ./theme.nix
    ./bluetooth.nix
  ];

  xdg.mimeApps = {
    enable = false;

    associations.added = {
      "application/pdf" = "zen.desktop";
    };

    defaultApplications = {
      "application/pdf" = [ "zen.desktop" ];
    };
  };
}
