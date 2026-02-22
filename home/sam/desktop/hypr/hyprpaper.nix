{
  services.hyprpaper = {
    enable = true;

    settings = {
      splash = false;

      wallpaper = [
        {
          monitor = "DP-1";
          path = "${./wallpaper.jpg}";
        }
        {
          monitor = "DP-2";
          path = "${./wallpaper.jpg}";
        }
        {
          monitor = "VIRT-1";
          path = "${./wallpaper.jpg}";
        }
      ];
    };
  };
}
