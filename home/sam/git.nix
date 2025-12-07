{
  lib,
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;

    signing = {
      signByDefault = true;
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJvAcV+VOvK8Gg2NqLp/CYMOHtydekmVO+GPQ2vrGprp";
    };

    settings = {
      user = {
        name = "Samuel Corsi-House";
        email = "sam@chouse.dev";
      };

      gpg = {
        format = "ssh";
        ssh.program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };

      pull.rebase = true;
      core.editor = "nano";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}
