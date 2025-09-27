{ pkgs, ... }:
{
  xdg.configFile."rofi/squared-nord.rasi" = {
    enable = true;
    source = ./squared-nord.rasi;
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;

    theme = "squared-nord.rasi";
    font = "MonoLisa Nerd Font Medium 12";
    plugins = with pkgs; [
      (rofi-calc.override {
        rofi-unwrapped = rofi-unwrapped;
      })
    ];
  };
}
