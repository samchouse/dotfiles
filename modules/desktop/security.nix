{
  den.aspects.security = {
    nixos = { pkgs, ... }: {
      security.rtkit.enable = true;

      services = {
        greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${pkgs.tuigreet}/bin/tuigreet -t --time-format '%a, %B %-d, %Y - %-I:%M %p' -r --user-menu --asterisks --power-shutdown 'systemctl poweroff' --power-reboot 'systemctl reboot'";
            };
            initial_session = {
              user = "sam";
              command = "${pkgs.hyprland}/bin/start-hyprland";
            };
          };
        };
      };

      systemd.user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
  };
}
