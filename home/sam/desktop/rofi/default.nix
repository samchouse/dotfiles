{ pkgs, ... }:
{
  xdg.configFile."rofi/squared-nord.rasi" = {
    enable = true;
    source = ./squared-nord.rasi;
  };

  programs.rofi = {
    enable = true;

    package = pkgs.rofi-wayland;
    theme = "squared-nord.rasi";
  };
}
