#!/usr/bin/env bash

set -e

FILENAME=$HOME/Pictures/Screenshots/$(date '+%Y-%m-%d_%H-%M-%S').png
mkdir -p "$HOME/Pictures/Screenshots"

wayfreeze --hide-cursor &
PID=$!
sleep .1
grim -g "$(slurp)" "$FILENAME"
kill $PID

wl-copy <"$FILENAME"
