{
  inputs,
  pkgs,
  ...
}:
{
  services.hypridle = {
    enable = true;

    settings = {
      listener = [
        {
          timeout = 60;
          on-timeout = "bash -c \"if pgrep -x 'hyprlock' > /dev/null; then openrgb -p Black && hyprctl dispatch dpms off && echo off >/tmp/usb-power; fi\"";
          on-resume = "bash -c \"openrgb -p Blue && hyprctl dispatch dpms on && echo on >/tmp/usb-power\"";
        }
        {
          timeout = 180;
          on-timeout = "bash -c \"if ! pgrep -x 'hyprlock' > /dev/null; then playerctl --player playerctld pause || true && openrgb -p Black && ~/.config/eww/scripts/lock.sh ss && hyprctl dispatch dpms off && echo off >/tmp/usb-power; fi\"";
          on-resume = "bash -c \"openrgb -p Blue && hyprctl dispatch dpms on && echo on >/tmp/usb-power\"";
        }
        {
          timeout = 300;
          on-timeout = "bash -c \"if ! pgrep -x 'hyprlock' > /dev/null; then ~/.config/eww/scripts/lock.sh; fi\"";
        }
      ];
    };
  };
}
