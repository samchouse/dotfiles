{
  services.hypridle = {
    enable = true;

    settings = {
      listener = [
        {
          timeout = 60;
          on-timeout = "pidof hyprlock && (openrgb -p Black && hyprctl dispatch dpms off && echo off >/tmp/usb-power)";
          on-resume = "openrgb -p Blue && hyprctl dispatch dpms on && echo on >/tmp/usb-power";
        }
        {
          timeout = 180;
          on-timeout = "pidof hyprlock || (~/.config/eww/scripts/lock.sh ss && openrgb -p Black && hyprctl dispatch dpms off && echo off >/tmp/usb-power)";
          on-resume = "openrgb -p Blue && hyprctl dispatch dpms on && echo on >/tmp/usb-power";
        }
        {
          timeout = 300;
          on-timeout = "pidof hyprlock || ~/.config/eww/scripts/lock.sh";
        }
      ];
    };
  };
}
