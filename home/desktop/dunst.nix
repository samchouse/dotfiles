{ ... }: {
  services.dunst =  {
    enable = true;

    iconTheme = "Adwaita";

    catpuccin = {
      enable = true;
      flavor = "macchiato";
    };

    settings = {
      global = {
        offset = "(30, 50)";
        dmenu = "/usr/bin/rofi -dmenu -p dunst:";
        
        icon_corner_radius = 10;
        progress_bar_corner_radius = 20;

        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };
    };
  };
}
