#!/bin/bash

SWAYLOCK_CMD="$HOME/.config/eww/scripts/lock.sh"

OPENRGB_ON_CMD="openrgb -p Blue"
OPENRGB_OFF_CMD="openrgb -p Black"

swayidle -w \
  timeout 180 "playerctl --player playerctld pause || true && $OPENRGB_OFF_CMD && hyprctl dispatch dpms off" resume "$OPENRGB_ON_CMD && hyprctl dispatch dpms on" \
  timeout 300 "$SWAYLOCK_CMD" \
  timeout 301 "hyprctl dispatch dpms off" resume "$OPENRGB_ON_CMD && hyprctl dispatch dpms on"
