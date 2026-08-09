{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "sweet";
  version = "latest";

  src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "Sweet";
    rev = "d44d76dc488bbe9588c065eacd7422a9333b1428";
    sha256 = "sha256-F+9zXXyCUVtNmuP8I42bPO1AgaC8kgoFM9IWGONSN7Y=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes/
    cp -r . $out/share/themes/Sweet-Ambar-Blue-Dark
    runHook postInstall
  '';
}
