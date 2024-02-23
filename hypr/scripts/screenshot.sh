#!/bin/bash

set -e

FILENAME=/tmp/$(
  echo $RANDOM | md5sum | head -c 10
  echo
).png
FINALNAME=$HOME/Pictures/Screenshots/$(date '+%Y-%m-%d_%H-%M-%S').png

grim -g "$(slurp -o -r -c '#ff0000ff')" "$FILENAME"
/home/sam/Documents/projects/personal/imgmath/target/release/imgmath -i "$FILENAME" -o "$FILENAME" reverse blf
/home/sam/Documents/projects/personal/imgmath/target/release/imgmath -i "$FILENAME" -o "$FILENAME" reverse blf
satty --filename "$FILENAME" --fullscreen --early-exit --copy-command wl-copy --output-filename "$FINALNAME" --save-after-copy
