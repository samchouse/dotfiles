#!/bin/bash

handle() {
  case $1 in monitoradded*|monitorremoved*)
    monitor="${1//monitoradded>>DP-/}"

    hyprctl dispatch workspace "$monitor"

    hyprpaper >>/dev/null 2>&1 &
    disown

    eww open-many topbar-left topbar-right
    ;;
  esac
}

socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do handle "$line"; done
