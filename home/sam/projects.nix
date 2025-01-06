{ pkgs, ... }:
{
  systemd.user.services.gerry-bot = {
    Unit = {
      After = [ "network.target" ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };

    Service = {
      Restart = "on-failure";
      Environment = [ "PATH=$PATH:${pkgs.devenv}/bin" ];
      WorkingDirectory = "/home/sam/Documents/projects/personal/gerry-bot";
      ExecStart = "${pkgs.direnv}/bin/direnv exec . bun start";
    };
  };
}
