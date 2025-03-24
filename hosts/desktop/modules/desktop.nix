{
  pkgs,
  ...
}@attrs:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.hyprland = {
    enable = true;
    package = pkgs.hypr.hyprland;
    portalPackage = pkgs.hypr.xdg-desktop-portal-hyprland;
  };
  xdg.portal = {
    enable = true;

    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet -t --time-format '%a, %B %-d, %Y - %-I:%M %p' -r --user-menu --asterisks --power-shutdown 'systemctl poweroff' --power-reboot 'systemctl reboot'";
        };
      };
    };

    udev.packages = [ pkgs.swayosd ];
    gnome.gnome-keyring.enable = true;
  };
  systemd = {
    services.swayosd-libinput-backend = {
      enable = true;

      wantedBy = [ "graphical-session.target" ];

      unitConfig = {
        Description = "SwayOSD LibInput backend for listening to certain keys like CapsLock, ScrollLock, VolumeUp, etc...";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Documentation = "https://github.com/ErikReider/SwayOSD";
      };

      serviceConfig = {
        Type = "dbus";
        BusName = "org.erikreider.swayosd";
        ExecStart = "${pkgs.swayosd}/bin/swayosd-libinput-backend";
        Restart = "on-failure";
      };
    };

    user.services.polkit-gnome-authentication-agent-1 = {
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

  fonts.packages =
    if attrs ? custom-fonts then
      [
        attrs.custom-fonts.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.material-symbols
      ]
    else
      [ pkgs.material-symbols ];
}
