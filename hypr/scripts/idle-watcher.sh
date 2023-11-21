#!/bin/bash

PIPE="/tmp/usb-lock"

SWAYLOCK_CMD="$HOME/.config/eww/scripts/lock.sh"

OPENRGB_ON_CMD="openrgb -p Blue"
OPENRGB_OFF_CMD="openrgb -p Black"

swayidle -w \
  timeout 60 "if pgrep -x 'swaylock' > /dev/null; then $OPENRGB_OFF_CMD && hyprctl dispatch dpms off && echo off >$PIPE; fi" \
  timeout 180 "if ! pgrep -x 'swaylock' > /dev/null; then playerctl --player playerctld pause || true && $OPENRGB_OFF_CMD && hyprctl dispatch dpms off; fi" resume "$OPENRGB_ON_CMD && hyprctl dispatch dpms on" \
  timeout 300 "if ! pgrep -x 'swaylock' > /dev/null; then hyprctl dispatch dpms on && $SWAYLOCK_CMD && hyprctl dispatch dpms off && echo off >$PIPE; fi"
