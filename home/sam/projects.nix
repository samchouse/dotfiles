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
      WorkingDirectory = "/home/sam/Documents/projects/personal/gerry-bot";
      ExecStart = "${pkgs.devenv}/bin/devenv shell bun start";
    };
  };

  systemd.user.services.tracker = {
    Unit = {
      After = [ "network.target" ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };

    Service = {
      Restart = "on-failure";
      WorkingDirectory = "/home/sam/Documents/projects/personal/tracker";
      ExecStart = "${pkgs.devenv}/bin/devenv shell bun start";
    };
  };
}
