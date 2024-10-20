{ pkgs, ... }:
{
  services.dunst = {
    enable = true;

    # iconTheme = "Adwaita";

    catppuccin = {
      enable = true;
      flavor = "macchiato";
    };

    settings = {
      global = {
        offset = "30x50";
        font = "Monolist Nerd Font 10";
        dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst:";

        corner_radius = 10;
        icon_corner_radius = 10;

        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };
    };
  };
}
