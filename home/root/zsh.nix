{
  programs.zsh = {
    enable = true;

    initContent = ''
      export SSH_AUTH_SOCK=''${SSH_AUTH_SOCK:-/home/sam/.1password/agent.sock}
    '';
  };
}
