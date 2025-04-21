{
  appimageTools,
  lib,
  requireFile,
  makeWrapper,
}:

appimageTools.wrapType2 rec {
  pname = "cider-2";
  version = "3.0.0-alpha";

  src = requireFile {
    name = "cider-linux-x64.AppImage";
    url = "https://cidercollective.itch.io/cider";
    sha256 = "sha256-bOaAOGPoCa9UxnE/gfmG3K0Xl2C8Qk42KL6oH8t8s2Y=";
  };

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands =
    let
      contents = appimageTools.extract {
        inherit version src;
        # HACK: this looks for a ${pname}.desktop, where `cider-2.desktop` doesn't exist
        pname = "Cider";
      };
    in
    ''
      wrapProgram $out/bin/${pname} \
        --add-flags "--no-sandbox --disable-gpu-sandbox" # Cider 2 does not start up properly without these from my preliminary testing

      install -m 444 -D ${contents}/Cider.desktop $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-warn 'Exec=Cider' 'Exec=${pname}'
      cp -r ${contents}/usr/share/icons $out/share
    '';

  meta = {
    description = "Powerful music player that allows you listen to your favorite tracks with style";
    homepage = "https://cider.sh";
    license = lib.licenses.unfree;
    mainProgram = "cider-2";
    maintainers = with lib.maintainers; [ itsvic-dev ];
    platforms = [ "x86_64-linux" ];
  };
}
