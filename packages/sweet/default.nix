{
  stdenv,
  fetchFromGitHub,
  lib,
  gtk-engine-murrine,
}:

stdenv.mkDerivation rec {
  pname = "sweet";
  version = "latest";

  src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "Sweet";
    rev = "cee419fb7794c4a441fd203d9a821429ab978d6e";
    sha256 = "sha256-rp1xtUawDiwrSV3J7RjKnb7qjhSqPDklJkeV1y1WBTQ=";
  };

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes/
    cp -r . $out/share/themes/Sweet-Ambar-Blue-Dark
    runHook postInstall
  '';
}
