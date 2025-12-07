{ pkgs, ... }:
{
  systemd.user.services = {
    gerry-bot = {
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

    gooners = {
      Unit = {
        After = [ "network.target" ];
      };

      Install = {
        WantedBy = [ "default.target" ];
      };

      Service = {
        Type = "forking";
        WorkingDirectory = "/home/sam/Documents/servers/Gooners";
        ExecStart = "/bin/sh -c '${pkgs.tmux}/bin/tmux start-server \; ${pkgs.tmux}/bin/tmux new-session -s gooners -d \\'devenv shell java -Xms4G -Xmx4G -jar server.jar --nogui\\''";
        ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t gooners";
        Environment = [ "TMUX_TMPDIR=/run/user/1000" ];
      };
    };
  };
}
