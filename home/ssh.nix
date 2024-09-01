{ ... }:
{
  programs.ssh = {
    enable = true;

    extraConfig = "IdentityAgent /home/sam/.1password/agent.sock";
  };
}
