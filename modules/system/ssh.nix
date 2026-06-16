{
  den.aspects.ssh = {
    homeManager = {
      programs.ssh = {
        enable = true;

        enableDefaultConfig = false;
        settings."Host *" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
          identityAgent = "$SSH_AUTH_SOCK";
        };
      };
    };
  };
}
