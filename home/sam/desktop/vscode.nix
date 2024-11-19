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
              sha256 = "sha256:0n85d90k1rk8sgx71gzjg9nz96s32a510d8cpcs0fzas8rngw1ww";
            }
          );

          buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
        });
  };
}
