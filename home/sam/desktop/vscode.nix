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
              sha256 = "sha256:1ai1wc0fsk4zk6pl17jvkkhc0cbfwzk7wyascxllppj6nrzsnjgp";
            }
          );

          buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
        });
  };
}
