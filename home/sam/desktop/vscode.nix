{
  lib,
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
        (oldAttrs: rec {
          version = "latest";
          src = (
            builtins.fetchTarball {
              url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
              sha256 = "sha256:0ikynk2vvnwxmxn4h3nxsk2sgd5r6hy27sh08d6bwq5ns74yy2lb";
            }
          );

          dontStrip = true;
          buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
        });
  };
}
