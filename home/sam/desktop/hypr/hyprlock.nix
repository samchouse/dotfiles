{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
      };

      background = [
        {
          monitor = "DP-2";
          path = "/tmp/hyprlock-1.png";
          blur_passes = 1;
          blur_size = 3;
        }
        {
          monitor = "DP-1";
          path = "/tmp/hyprlock-2.png";
          blur_passes = 1;
          blur_size = 3;
        }
        {
          monitor = "VIRT-1";
          path = "/tmp/hyprlock-3.png";
          blur_passes = 1;
          blur_size = 3;
        }
      ];

      label = [
        {
          monitor = "";
          text = "cmd[update:1000] echo \"<span font-weight='heavy'>$(date '+%-I:%M %p')</span>\"";
          color = "rgb(228, 228, 231)";
          font_size = 100;
          font_family = "Noto Sans";

          position = "0, -140";
          halign = "center";
          valign = "top";
        }

        {
          monitor = "";
          text = "cmd[update:1000] echo \"<span font-weight='semibold' color='##a1a1aa'>$(date '+%a, %B %-e, %Y')</span>\"";
          color = "rgb(228, 228, 231)";
          font_size = 25;
          font_family = "Noto Sans";

          position = "0, -100";
          halign = "center";
          valign = "top";
        }
      ];

      input-field = {
        monitor = "";
        size = "250, 50";
        outline_thickness = 5;
        outer_color = "rgb(24, 24, 27)";
        inner_color = "rgb(24, 24, 27)";
        fade_on_empty = false;
        placeholder_text = "<span color=\"##f4f4f5\">Password</span>";
        hide_input = true;
        rounding = -1;
        check_color = "rgb(199, 210, 254)";
        fail_color = "rgb(185, 28, 28)";
        fail_text = "$FAIL <b>($ATTEMPTS)</b>";
        capslock_color = "rgb(253, 230, 138)";

        position = "0, 50";
        halign = "center";
        valign = "bottom";
      };
    };
  };
}
