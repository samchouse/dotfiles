#!/usr/bin/env bash

handle() {
  case $1 in monitoradded\>\>* | monitorremoved\>\>*)
    reinit="${1//monitoradded>>DP-/}"
    if [[ $reinit -eq 1 ]]; then
      reinit=2
    elif [[ $reinit -eq 2 ]]; then
      reinit=1
    fi

    workspace=$(hyprctl activeworkspace | grep -oP "\(\d\)" | grep -oP "\d")
    hyprctl dispatch workspace "$reinit"
    eww open-many topbar-left topbar-right >>/dev/null 2>&1
    hyprctl dispatch workspace "$workspace"

    if pgrep -x "hyprlock" >/dev/null; then
      hyprctl dispatch dpms off
    fi
    ;;
  esac
}

socat -u "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do handle "$line"; done
