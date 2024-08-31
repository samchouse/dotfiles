{
  inputs,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "NVD_BACKEND,direct"
      ];

      cursor = {
        allow_dumb_copy = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 0;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";
      };

      decoration = {
        rounding = 10;

        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";

        blur = {
          enabled = true;
          size = 3;
          passes = 2;
          new_optimizations = true;
        };
      };

      animations = {
        enabled = true;

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      input = {
        kb_layout = "us";
        follow_mouse = 2;
        sensitivity = 0;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      monitor = [
        "DP-2,2560x1440@144,0x0,1"
        "DP-1,2560x1440@60,2560x0,1"
        ",preferred,auto,auto"
      ];

      workspace = [
        "1,monitor:DP-2,default:true"
        "2,monitor:DP-1,default:true"
      ];

      layerrule = [
        "blur, gtk-layer-shell"
        "ignorezero, gtk-layer-shell"
      ];

      windowrulev2 = [
        # Screenshotting
        "move -2560 0,title:^(flameshot)"
        "suppressevent fullscreen,title:^(flameshot)"
        "float,class:^(flameshot)$,title:^(flameshot)"
        "monitor DP-1,class:^(flameshot)$,title:^(flameshot)"
        "size 5120 1440,class:^(flameshot)$,title:^(flameshot)"

        # Screensharing
        "noanim,class:^(xwaylandvideobridge)$"
        "nofocus,class:^(xwaylandvideobridge)$"
        "noinitialfocus,class:^(xwaylandvideobridge)$"
        "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
      ];

      "$mod" = "SUPER";
      bind =
        [
          "$mod, TAB, exec, kitty"
          "$mod, Q, killactive, "
          "$mod, M, exit, "
          "$mod, V, togglefloating, "
          "$mod, P, pseudo, "
          "$mod, J, togglesplit, "
          "$mod, S, exec, ~/.config/hypr/scripts/screenshot.sh"
          "$mod, space, exec, rofi -show drun -show-icons -icon-theme 'Kora' -sort -sorting-method fzf"
          "$mod SHIFT, space, exec, rofi -show calc -modi calc -no-show-match -no-sort"

          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Scroll through existing workspaces with mod + scroll
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (
            builtins.genList (
              x:
              let
                ws =
                  let
                    c = (x + 1) / 10;
                  in
                  builtins.toString (x + 1 - (c * 10));
              in
              [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            ) 10
          )
        );

      bindm = [
        # Move/resize windows with mod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      binde = [
        # Volume keys
        ", XF86AudioNext, exec, playerctl --player playerctld next"
        ", XF86AudioPrev, exec, playerctl --player playerctld previous"
        ", XF86AudioPlay, exec, playerctl --player playerctld play-pause"
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
      ];

      exec-once = [
        "gammastep -O 4000 >>/dev/null 2>&1"
      ];
    };
  };
}
