#!/usr/bin/env bash

set -e

FILENAME=$HOME/Pictures/Screenshots/$(date '+%Y-%m-%d_%H-%M-%S').png
mkdir -p "$HOME/Pictures/Screenshots"

trap 'kill $PID' EXIT

wayfreeze --hide-cursor &
PID=$!
sleep .1

AREA=$(slurp)
sleep .2
grim -g "$AREA" "$FILENAME"

wl-copy <"$FILENAME"
