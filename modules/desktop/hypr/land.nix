{ den, ... }: {
  den.aspects.hyprland = {
    includes = [
      den.aspects.theme
      den.aspects.dunst
      den.aspects.vicinae
      den.aspects.sunshine
      den.aspects.security
    ];

    nixos = {
      programs.hyprland.enable = true;
      xdg.portal.xdgOpenUsePortal = true;
      security.pam.services.hyprlock = { };
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    };

    homeManager = { pkgs, ... }: {
      xdg.configFile."hypr/scripts" = {
        source = ./scripts;
        recursive = true;
      };

      home = {
        sessionVariables = {
          QT_QPA_PLATFORM = "wayland";
        };

        pointerCursor = {
          gtk.enable = false;
          x11.enable = true;
          package = pkgs.niqs.bibata-hyprcursor;
          name = "Bibata-modern";
          size = 24;
        };
      };

      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;

        configType = "hyprlang";
        settings = {
          env = [
            "NVD_BACKEND,direct"
            "LIBVA_DRIVER_NAME,nvidia"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"

            "HYPRCURSOR_SIZE,24"
            "HYPRCURSOR_THEME,Bitbata-modern"
            "XCURSOR_SIZE,24"
            "XCURSOR_THEME,Bibata-Modern-Classic"

            "XDG_SESSION_TYPE,wayland"
            "ELECTRON_OZONE_PLATFORM_HINT,auto"

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

          dwindle.preserve_split = true;

          monitor = [
            ",preferred,auto,auto"
          ];

          workspace = [
            "1,monitor:VIRT-1,default:true"
          ];

          layerrule = [
            "blur on, match:namespace gtk-layer-shell"
            "ignore_alpha 0, match:namespace gtk-layer-shell"
            "no_anim on, match:namespace gtk4-layer-shell"

            "blur on, match:namespace vicinae"
            "ignore_alpha 0, match:namespace vicinae"
            "no_anim on, match:namespace vicinae"
          ];

          "$mod" = "SUPER";
          bind = [
            "$mod, TAB, exec, kitty"
            "$mod, Q, killactive, "
            "$mod, M, exec, hyprshutdown"
            "$mod SHIFT, V, togglefloating, "
            "$mod, P, pseudo, "
            "$mod, J, layoutmsg, togglesplit"
            "$mod, F, fullscreen, "
            "$mod, S, exec, ~/.config/hypr/scripts/screenshot.sh"
            "$mod, space, exec, vicinae toggle"
            "$mod, V, exec, vicinae vicinae://extensions/vicinae/clipboard/history"
            "$mod, B, exec, hyprctl -j getoption binds:disable_keybind_grabbing | jq '.int | (. + 1) % 2' | xargs hyprctl keyword binds:disable_keybind_grabbing"

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

          exec-once = [
            "$HOME/.config/hypr/scripts/startup.sh"
          ];
        };
      };
    };
  };
}
