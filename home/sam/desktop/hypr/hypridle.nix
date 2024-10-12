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
          on-timeout = "bash -c \"if pgrep -x 'hyprlock' > /dev/null; then openrgb -p Black && hyprctl dispatch dpms off; fi\"";
          #   on-timeout = "bash -c \"if pgrep -x 'hyprlock' > /dev/null; then openrgb -p Black && hyprctl dispatch dpms off && echo off >/tmp/usb-lock; fi\"";
        }
        {
          timeout = 180;
          on-timeout = "bash -c \"if ! pgrep -x 'hyprlock' > /dev/null; then playerctl --player playerctld pause || true && openrgb -p Black && hyprctl dispatch dpms off; fi\"";
          on-resume = "bash -c \"openrgb -p Blue && hyprctl dispatch dpms on\"";
        }
        {
          timeout = 300;
          on-timeout = "bash -c \"if ! pgrep -x 'hyprlock' > /dev/null; then hyprctl dispatch dpms on && ~/.config/eww/scripts/lock.sh && hyprctl dispatch dpms off; fi\"";
          #   on-timeout = "bash -c \"if ! pgrep -x 'hyprlock' > /dev/null; then hyprctl dispatch dpms on && ~/.config/eww/scripts/lock.sh && hyprctl dispatch dpms off && echo off >/tmp/usb-lock; fi\"";
        }
      ];
    };
  };
}
