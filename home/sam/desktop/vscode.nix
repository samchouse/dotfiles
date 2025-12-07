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
              sha256 = "sha256:1cw5ma2c9bbx9d8w6ivl7r7qj2p7k3l7d3nzh6rd22g55gpszwwq";
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
