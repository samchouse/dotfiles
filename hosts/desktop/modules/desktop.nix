{
  pkgs,
  ...
}@attrs:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  security.pam.services.hyprlock = { };
  programs = {
    hyprland = {
      enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
  };
  xdg.portal = {
    enable = true;

    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  services = {
    sunshine = {
      enable = true;
      capSysAdmin = true;
      openFirewall = true;
      applications = {
        env = {
          PATH = "$(PATH):$(HOME)/.local/bin";
        };
        apps = [
          {
            name = "Desktop";
            image-path = "desktop.png";
          }
        ];
      };
      settings = {
        output_name = "0";
        global_prep_cmd = builtins.toJSON [
          {
            do = "sh -c \"hyprctl keyword monitor VIRT-1,\${SUNSHINE_CLIENT_WIDTH}x\${SUNSHINE_CLIENT_HEIGHT}@\${SUNSHINE_CLIENT_FPS},5120x0,1\"";
          }
          {
            do = "bash -c \"pkill gjs || true; ags run & disown\"";
          }
          {
            do = "sh -c \"pkill -USR1 hyprlock || true\"";
            undo = "/home/sam/.config/hypr/scripts/lock.sh";
          }
        ];
      };
    };

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

  fonts.packages =
    if attrs ? custom-fonts then
      [
        attrs.custom-fonts.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.material-symbols
      ]
    else
      [ pkgs.material-symbols ];
}
