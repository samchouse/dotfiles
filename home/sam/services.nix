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

    tmux = {
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Unit = {
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "forking";
        ExecStart = "${pkgs.tmux}/bin/tmux new-session -s main -d";
        ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t main";
        Environment = [ "TMUX_TMPDIR=/run/user/1000" ];
      };
    };
  };
}
