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

if ! pgrep -x "swaylock" > /dev/null; then
  playerctl --player playerctld pause || true
  eval "$SWAYLOCK_CMD"
fi
