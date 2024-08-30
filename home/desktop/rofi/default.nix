{ ... }: {
  services.rofi = {
    enable = true;

    theme = builtins.readFile(./. + "/squared-nord.rasi")
  };
}
