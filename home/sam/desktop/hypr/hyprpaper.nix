{
  services.hyprpaper = {
    enable = true;

    settings = {
      splash = false;
      preload = "${./wallpaper.jpg}";

      wallpaper = [
        "DP-1,${./wallpaper.jpg}"
        "DP-2,${./wallpaper.jpg}"
        "VIRT-1,${./wallpaper.jpg}"
      ];
    };
  };
}
