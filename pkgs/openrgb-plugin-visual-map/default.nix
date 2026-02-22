{
  lib,
  stdenv,
  fetchFromGitLab,
  glib,
  openal,
  hidapi,
  pipewire,
  pkg-config,
  qt6Packages,
  openrgb,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openrgb-plugin-visual-map";
  version = openrgb.version;

  src = fetchFromGitLab {
    owner = "OpenRGBDevelopers";
    repo = "OpenRGBVisualMapPlugin";
    tag = "release_candidate_${finalAttrs.version}";
    hash = "sha256-XrYqDFj4tlIL0fEpWbtrKMwC08rtN1whIK6INi4qy+s=";
    fetchSubmodules = true;
  };

  qmakeFlags = [
    "CONFIG+=link_pkgconfig"
    "PKGCONFIG+=libpipewire-0.3"
    "QT_TOOL.lrelease.binary=${lib.getDev qt6Packages.qttools}/bin/lrelease"
  ];

  nativeBuildInputs = [
    pkg-config
    qt6Packages.wrapQtAppsHook
    qt6Packages.qmake
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qt5compat
    glib
    openal
    hidapi
    pipewire
  ];
})
