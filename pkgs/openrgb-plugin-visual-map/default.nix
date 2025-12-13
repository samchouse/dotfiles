{
  stdenv,
  fetchFromGitLab,
  glib,
  pkg-config,
  kdePackages,
  version,
  lib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openrgb-plugin-visual-map";
  version = version;

  src = fetchFromGitLab {
    owner = "OpenRGBDevelopers";
    repo = "OpenRGBVisualMapPlugin";
    rev = "release_candidate_${finalAttrs.version}";
    hash = "sha256-XrYqDFj4tlIL0fEpWbtrKMwC08rtN1whIK6INi4qy+s=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    kdePackages.wrapQtAppsHook
    kdePackages.qmake
  ];

  buildInputs = [
    kdePackages.qtbase
    kdePackages.qt5compat
    glib
  ];

  qmakeFlags = [
    "QT_TOOL.lrelease.binary=${lib.getDev kdePackages.qttools}/bin/lrelease"
  ];
})
