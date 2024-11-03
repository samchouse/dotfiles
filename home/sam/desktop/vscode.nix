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
              sha256 = "sha256:187pj9ygnzxg91zkvq7ic9a11c7zidbgaqvlvkagm186wl5bzw67";
            }
          );

          buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
        });
  };
}
