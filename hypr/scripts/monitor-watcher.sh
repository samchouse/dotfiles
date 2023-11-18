#!/bin/bash

# TODO: support monitorremoved

handle() {
  case $1 in monitoradded*)
    monitor="${1//monitoradded>>DP-/}"

    hyprctl dispatch focusmonitor "$monitor"
    hyprctl dispatch workspace "$monitor"

    hyprpaper >>/dev/null 2>&1 &
    hyprctl hyprpaper wallpaper "DP-$monitor,~/Pictures/wallpaper.jpg"

    eww open-many topbar-left topbar-right
    ;;
  esac
}

socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do handle "$line"; done
