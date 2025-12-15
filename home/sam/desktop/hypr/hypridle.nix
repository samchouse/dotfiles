{
  services.hypridle = {
    enable = true;

    settings = {
      listener = [
        {
          timeout = 60;
          on-timeout = "pidof hyprlock && ~/.config/eww/scripts/lock.sh misc off";
          on-resume = "~/.config/eww/scripts/lock.sh misc on";
        }
        {
          timeout = 180;
          on-timeout = "pidof hyprlock || (~/.config/eww/scripts/lock.sh ss && ~/.config/eww/scripts/lock.sh misc off)";
          on-resume = "~/.config/eww/scripts/lock.sh misc on";
        }
        {
          timeout = 300;
          on-timeout = "pidof hyprlock || ~/.config/eww/scripts/lock.sh";
        }
      ];
    };
  };
}
