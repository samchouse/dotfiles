#!/bin/bash

SWAYLOCK_CMD="swaylock \
  -fSle \
  --indicator \
  --indicator-radius 110 \
  --indicator-idle-visible \
  --clock \
  --timestr \"%-l:%M %p\" \
  --datestr \"%a, %B %-e, %Y\" \
  --effect-blur 5x5"

OPENRGB_ON_CMD="openrgb -p Blue"
OPENRGB_OFF_CMD="openrgb -p Black"

swayidle -w \
  timeout 180 "$SWAYLOCK_CMD --grace 120" \
  timeout 300 "$OPENRGB_OFF_CMD && hyprctl dispatch dpms off" resume "$OPENRGB_ON_CMD && hyprctl dispatch dpms on" \
  before-sleep "$OPENRGB_OFF_CMD && $SWAYLOCK_CMD" \
  after-resume "$OPENRGB_ON_CMD"
