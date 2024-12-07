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
              sha256 = "sha256:16xpv4yrxdcljbmjimyzi6m3lwxa7kfny5y7k6m95wd79c05lyzk";
            }
          );

          buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
        });
  };
}
