#!/bin/bash

SWAYLOCK_CMD="swaylock \
  -fSle \
  --indicator \
  --indicator-radius 110 \
  --indicator-idle-visible \
  --clock \
  --timestr \"%-l:%M %p\" \
  --datestr \"%a, %b %-e, %Y\" \
  --effect-blur 5x5"

OPENRGB_ON_CMD="openrgb -p Blue"
OPENRGB_OFF_CMD="openrgb -p Black"

swayidle -w \
  timeout 180 "hyprctl dispatch dpms off" resume "hyprctl dispatch dpms on" \
  timeout 300 "hyprctl dispatch dpms on && systemctl suspend" \
  before-sleep "$OPENRGB_OFF_CMD && $SWAYLOCK_CMD" \
  after-resume "$OPENRGB_ON_CMD"
