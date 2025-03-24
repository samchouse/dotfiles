{
  programs.zsh = {
    enable = true;

    initExtra = ''
      [ -z "$SSH_TTY" ] && [ -n "$SSH_CONNECTION" ] && export SSH_TTY="/dev/pts/9999"
      [ -n "$SSH_CONNECTION" ] && export SSH_AUTH_SOCK=$(ls -t /tmp/auth-agent**/* | head -1)
      export SSH_AUTH_SOCK=''${SSH_AUTH_SOCK:-/home/sam/.1password/agent.sock}
    '';
  };
}
