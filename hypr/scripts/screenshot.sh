#!/bin/bash

set -e

FINALNAME=$HOME/Pictures/Screenshots/$(date '+%Y-%m-%d_%H-%M-%S').png
grim -g "$(slurp -o -r -c '#ff0000ff')" - | satty --filename - --fullscreen --early-exit --copy-command wl-copy --output-filename "$FINALNAME" --save-after-copy
