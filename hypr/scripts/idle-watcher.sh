#!/bin/bash

SWAYLOCK_CMD="swaylock \
	-fSle \
	--indicator \
	--indicator-radius 110 \
	--indicator-idle-visible \
	--clock \
	--timestr \"%l:%M %p\" \
	--datestr \"%a, %B %e, %Y\" \
	--effect-blur 5x5 \
	--grace 120"

swayidle -w \
	timeout 180 "$SWAYLOCK_CMD" \
	timeout 300 'openrgb -p Black && hyprctl dispatch dpms off' resume 'openrgb -p Blue && hyprctl dispatch dpms on'
