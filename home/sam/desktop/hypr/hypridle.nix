{
  services.hypridle = {
    enable = true;

    settings = {
      listener = [
        {
          timeout = 60;
          on-timeout = "pidof hyprlock && ~/.config/hypr/scripts/lock.sh misc off";
          on-resume = "~/.config/hypr/scripts/lock.sh misc on";
        }
        {
          timeout = 180;
          on-timeout = "pidof hyprlock || (~/.config/hypr/scripts/lock.sh ss && ~/.config/hypr/scripts/lock.sh misc off)";
          on-resume = "~/.config/hypr/scripts/lock.sh misc on";
        }
        {
          timeout = 300;
          on-timeout = "pidof hyprlock || ~/.config/hypr/scripts/lock.sh";
        }
      ];
    };
  };
}
