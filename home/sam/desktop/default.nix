{ ... }:
{
  imports = [
    ./hypr
    ./rofi
    ./eww
    ./dunst.nix
    ./kitty.nix
    ./vscode.nix
    ./theme.nix
    ./bluetooth.nix
  ];

  xdg.mimeApps = {
    enable = true;

    associations.added = {
      "application/pdf" = "firefox.desktop";
    };

    defaultApplications = {
      "application/pdf" = [ "firefox.desktop" ];
    };
  };
}
