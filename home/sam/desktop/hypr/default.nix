{ ... }:
{
  imports = [
    ./hyprland.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
  ];

  xdg.configFile."hypr/scripts" = {
    source = ./scripts;
    recursive = true;
  };
}
