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
        commandLineArgs = "--password-store='basic'";
      }).overrideAttrs
        (oldAttrs: {
          version = "latest";
          src = (
            fetchTarball {
              url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
              sha256 = "sha256:1v1r8vq41dmxaifqhfhgji12qwgm44xanwbihrv3319384s8bf5f";
            }
          );
        });
  };
}
