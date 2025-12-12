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
              sha256 = "sha256:1nla5k660lpwhqfa0v6r59gn3kaimvwlv32svk4h3hh6zhb7qa3m";
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
