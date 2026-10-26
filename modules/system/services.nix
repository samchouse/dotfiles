{
  den.aspects.services = {
    homeManager =
      { pkgs, ... }:
      {
        systemd.user.services = {
          tmux = {
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };

            Unit = {
              After = [ "graphical-session.target" ];
              Wants = [ "gooners.service" ];
            };

            Service = {
              Type = "forking";
              ExecStart = "${pkgs.tmux}/bin/tmux new-session -s main -d";
              ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t main";
              Environment = [ "TMUX_TMPDIR=/run/user/1000" ];
            };
          };

          gooners = {
            Unit = {
              After = [ "tmux.service" ];
              Requires = [ "tmux.service" ];
            };

            Service = {
              Type = "oneshot";
              RemainAfterExit = true;
              WorkingDirectory = "/home/sam/Documents/servers/Gooners Reborn";
              ExecStart = "${pkgs.tmux}/bin/tmux new-session -s gooners -d devenv shell java -Xms4G -Xmx4G -jar server.jar --nogui";
              ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t gooners";
              Environment = [ "TMUX_TMPDIR=/run/user/1000" ];
            };
          };
        };
      };
  };
}
