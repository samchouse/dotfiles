{
  pkgs,
  ...
}:
{
  services.swayosd.enable = true;

  home.pointerCursor = {
    gtk.enable = false;
    x11.enable = true;
    package = pkgs.niqs.bibata-hyprcursor;
    name = "Bibata-modern";
    size = 24;
  };

  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;

    settings = {
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "NVD_BACKEND,direct"
        "XDG_SESSION_TYPE,wayland"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_THEME,Bitbata-modern"
        "HYPRCURSOR_SIZE,24"
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "PATH,$PATH:${pkgs.qt6Packages.qtstyleplugin-kvantum}/bin"
      ];

      misc = {
        enable_anr_dialog = false;
        focus_on_activate = true;
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
        kb_options = "ctrl:nocaps";
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      monitor = [
        "DP-2,2560x1440@144,0x0,1"
        "DP-1,2560x1440@60,2560x0,1"
        # "VIRT-1,preferred,7680x2880,auto"
        ",preferred,auto,auto"
      ];

      workspace = [
        "1,monitor:DP-2,default:true"
        "2,monitor:DP-1,default:true"
        "10,monitor:VIRT-1,default:true"
      ];

      layerrule = [
        "blur, gtk-layer-shell"
        "ignorezero, gtk-layer-shell"
        "noanim, gtk4-layer-shell"

        "blur, vicinae"
        "ignorealpha 0, vicinae"
        "noanim, vicinae"
      ];

      windowrulev2 = [
        "idleinhibit always, class:^Minecraft"
        "fullscreen, class:^(Minecraft 1.8.9)$"

        "idleinhibit always, class:^(Lethal Company)$"
        "fullscreen, class:^(Lethal Company)$"

        "idleinhibit always, title:^Brawlhalla$"
        "fullscreen, title:^Brawlhalla$"

        "idleinhibit always, title:^Rivals2"

        "float, class:(clipse)"
        "size 622 652, class:(clipse)"
      ];

      "$mod" = "SUPER";
      bind = [
        "$mod, TAB, exec, kitty"
        "$mod, Q, killactive, "
        # "$mod, M, exit, "
        "$mod SHIFT, V, togglefloating, "
        "$mod, P, pseudo, "
        "$mod, J, togglesplit, "
        "$mod, F, fullscreen, "
        "$mod, S, exec, ~/.config/hypr/scripts/screenshot.sh"
        "$mod, space, exec, vicinae toggle"
        "$mod, V, exec, kitty --class clipse -e clipse"

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
        # binds $mod + [shift +] {0-9} to [move to] workspace {1..10}
        builtins.concatLists (
          builtins.genList (
            x:
            let
              ws =
                let
                  c = (x + 1) / 10;
                in
                toString (x + 1 - (c * 10));
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
        "clipse -listen >>/dev/null 2>&1"
        "gammastep -O 4000 >>/dev/null 2>&1"
        "hyprctl output create headless VIRT-1 >>/dev/null 2>&1"
        "$HOME/.config/hypr/scripts/startup.sh >>/dev/null 2>&1"
        "$HOME/.config/hypr/scripts/monitor-watcher.sh >>/dev/null 2>&1"
      ];
    };
  };
}
