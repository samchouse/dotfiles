#!/bin/bash

if ! pgrep -x "hyprlock" > /dev/null; then
  playerctl --player playerctld pause || true
  hyprlock
fi
