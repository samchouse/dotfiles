{
  lib,
  pkgs,
  ...
}:
let
  sweet = pkgs.fetchFromGitHub {
    owner = "EliverLara";
    repo = "Sweet";
    rev = "926ed1928f451b45b728f0ae72990c5576c507d4";
    sha256 = "sha256-bX+hwYpJQkwEuh4E23q4jW84c769NYojrsuAyGU14gg=";
  };

  qtctConfig = ''
    [Appearance]
    icon_theme=kora
    style=kvantum-dark
    standard_dialogs=xdgdesktopportal
  '';
in
{
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  xdg.configFile = {
    "Kvantum" = {
      source = "${sweet}/kde/kvantum";
      recursive = true;
    };

    "Kvantum/kvantum.kvconfig".text = ''
      theme=Sweet-Ambar-Blue
    '';

    "qt5ct/qt5ct.conf".text = qtctConfig;
    "qt6ct/qt6ct.conf".text = qtctConfig;
  };

  gtk = {
    enable = true;

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    iconTheme = {
      name = "Kora";
      package = pkgs.kora-icon-theme;
    };

    theme = {
      name = "Sweet-Ambar-Blue";
      package = pkgs.sweet;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
