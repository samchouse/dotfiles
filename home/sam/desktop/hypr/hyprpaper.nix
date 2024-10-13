{
  inputs,
  pkgs,
  ...
}:
{
  services.hyprpaper = {
    enable = true;

    settings = {
      splash = false;
      preload = builtins.toString ./wallpaper.jpg;

      wallpaper = [
        "DP-1,${builtins.toString ./wallpaper.jpg}"
        "DP-2,${builtins.toString ./wallpaper.jpg}"
      ];
    };
  };
}
