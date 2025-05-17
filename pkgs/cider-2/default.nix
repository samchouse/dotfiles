{
  stdenv,
  lib,
  fetchurl,
  rpmextract,
  autoPatchelfHook,
  xorg,
  libxcb,
  glib,
  nss,
  nspr,
  dbus,
  atk,
  at-spi2-atk,
  gtk3,
  pango,
  cairo,
  cups,
  mesa,
  libxkbcommon,
  libepoxy,
  expat,
  systemd,
  alsa-lib,
  at-spi2-core,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "cider";
  version = "3.0.0-rc1";

  src = fetchurl rec {
    name = "cider-v${builtins.elemAt (lib.splitString "-" version) 0}-linux-x64.rpm";
    url = "https://repo.cider.sh/rpm/RPMS/${name}";
    sha256 = "sha256-Xc7EHvTTXwvy1+bqpIPGVWQ78tGUxXLnkRjDOqZI+8Y=";
  };

  nativeBuildInputs = [
    rpmextract
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [
    stdenv.cc.cc.lib
    xorg.libX11
    xorg.libXext
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXfixes
    xorg.libXrandr
    libxcb
    glib
    nss
    nspr
    dbus
    atk
    at-spi2-atk
    gtk3
    pango
    cairo
    cups
    mesa
    libxkbcommon
    libepoxy
    expat
    systemd
    alsa-lib
    at-spi2-core
  ];

  unpackPhase = ''
    rpmextract $src
    rm -r usr/lib/.build-id
  '';

  installPhase = ''
    runHook preInstall

    mv usr $out

    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/Cider \
      --add-flags "--no-sandbox --disable-gpu-sandbox"
    mv $out/bin/Cider $out/bin/cider
    substituteInPlace $out/share/applications/Cider.desktop \
      --replace-warn 'Exec=Cider' 'Exec=cider'
  '';

  meta = {
    description = "Powerful music player that allows you listen to your favorite tracks with style";
    homepage = "https://cider.sh";
    license = lib.licenses.unfree;
    mainProgram = "cider";
    maintainers = with lib.maintainers; [ itsvic-dev ];
    platforms = [ "x86_64-linux" ];
  };
}
