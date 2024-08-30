{ ... }: {
  programs.git = {
    enable = true;

    userName = "Samuel Corsi-House";
    userEmail = "sam@chouse.dev";

    signing = {
      signByDefault = true;
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJvAcV+VOvK8Gg2NqLp/CYMOHtydekmVO+GPQ2vrGprp"
    };

    extraConfig = {
      gpg.format = "ssh";
      pull.rebase = false;
      core.editor = "nano";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}