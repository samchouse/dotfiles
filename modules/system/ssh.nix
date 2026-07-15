{
  den.aspects.ssh = {
    homeManager = { host, ... }: {
      programs.ssh = {
        enable = true;

        enableDefaultConfig = false;
        settings = {
          "Host *".identityAgent =
            if host.class == "nixos" then
              "$SSH_AUTH_SOCK"
            else
              "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";

          "Host desktop".forwardAgent = true;
        };
      };
    };
  };
}
