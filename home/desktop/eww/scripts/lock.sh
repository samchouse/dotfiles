#!/bin/bash

case $1 in
"work")
  grim -o DP-1 /tmp/hyprlock-2.png
  grim -o DP-2 /tmp/hyprlock-1.png

  hyprlock &
  ;;
*)
  if ! pgrep -x "hyprlock" >/dev/null; then
    playerctl --player playerctld pause || true
    
    if [ "$1" == "eww" ]; then
      $0 work &
    else
      $0 work
    fi
  fi
  ;;
esac
