{
  imports = [
    ./hypr
    ./eww
    ./ags
    ./neovim
    ./discord
    ./niri.nix
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
