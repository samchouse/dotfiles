{
  pkgs,
  ...
}:
let
  sweet = pkgs.fetchFromGitHub {
    owner = "EliverLara";
    repo = "Sweet";
    rev = "e886a8acfa7f6a0816db03160f8b942874f2153a";
    sha256 = "sha256-3n70aJrnTRQ8CU3cXx2noHTQrbW1VcNwpuBym/3Yu/w=";
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

  home.sessionPath = [ "${pkgs.qt6Packages.qtstyleplugin-kvantum}/bin" ];

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
      name = "Sweet-Ambar-Blue-Dark";
      package = (pkgs.callPackage ../../../pkgs/sweet { });
    };
  };
}
