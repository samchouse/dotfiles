{ pkgs, ... }:
{
  systemd.user.services = {
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
