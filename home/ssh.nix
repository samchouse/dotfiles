{
  programs.ssh = {
    enable = true;

    extraConfig = "IdentityAgent $SSH_AUTH_SOCK";
  };
}
