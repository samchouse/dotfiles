{
  pkgs,
  ...
}:
{
  programs.vscode = {
    enable = true;
    package =
      (pkgs.vscode.override {
        isInsiders = true;
        commandLineArgs = "--password-store='gnome-libsecret'";
      }).overrideAttrs
        (oldAttrs: {
          version = "latest";
          src = (
            builtins.fetchTarball {
              url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
              sha256 = "sha256:0vmajw1i6mjhrvy30pkvwil5paszc4wzbrb90fmxi5zxxarxxc3c";
            }
          );
          buildInputs =
            with pkgs;
            [
              curl
              openssl
              webkitgtk_4_1
              libsoup_3
            ]
            ++ oldAttrs.buildInputs;
        });
  };
}
