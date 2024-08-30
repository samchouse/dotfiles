{ ... }: {
  programs.zsh = {
    enable = true;

    shellAliases = {
      u = "topgrade";
      c = "code-insiders --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations";
    };

    oh-my-zsh = {
      enable = true;

      plugins = [
        "git"
        "zsh-fast-syntax-highlighting"
      ];
    };
  };

  programs.starship = {
    enable = true;
  };
}
