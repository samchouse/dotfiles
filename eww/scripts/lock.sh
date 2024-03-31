#!/bin/bash

if ! pgrep -x "hyprlock" > /dev/null; then
  playerctl --player playerctld pause || true

  grim -o DP-1 /tmp/hyprlock-2.png
  grim -o DP-2 /tmp/hyprlock-1.png

  hyprlock
fi
