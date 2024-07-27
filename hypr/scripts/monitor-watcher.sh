#!/bin/bash

handle() {
  case $1 in monitoradded*|monitorremoved*)
    monitor="${1//monitoradded>>DP-/}"

    hyprctl dispatch workspace "$monitor"

    hyprpaper >>/dev/null 2>&1 &
    disown

    eww open-many topbar-left topbar-right

    if pgrep -x "hyprlock" >/dev/null; then
      hyprctl dispatch dpms off
    fi
    ;;
  esac
}

socat -u "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do handle "$line"; done
