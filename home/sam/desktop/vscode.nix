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
              sha256 = "sha256:19m9yrmr7hk08ydd1frs2ibnvncnjjfi0xgjwqarpkfvn9j81vjb";
            }
          );

          buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
        });
  };
}
