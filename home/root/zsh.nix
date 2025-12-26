{
  programs.zsh = {
    enable = true;

    initContent = ''
      [ -z "$SSH_TTY" ] && [ -n "$SSH_CONNECTION" ] && export SSH_TTY="/dev/pts/9999"
      [ -n "$SSH_CONNECTION" ] && export SSH_AUTH_SOCK=$(ls -t /tmp | rg auth-agent | head -1 | xargs -I {} echo /tmp/{}/listener.sock)
      export SSH_AUTH_SOCK=''${SSH_AUTH_SOCK:-/home/sam/.1password/agent.sock}
    '';
  };
}
