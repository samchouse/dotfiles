{
  den.aspects.hyprland = {
    homeManager = {
      services.hyprpaper = {
        enable = true;

        settings = {
          splash = false;

          wallpaper = [
            {
              monitor = "VIRT-1";
              path = "${./wallpaper.jpg}";
            }
          ];
        };
      };
    };
  };
}
