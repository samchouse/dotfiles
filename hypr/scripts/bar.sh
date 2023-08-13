#!/bin/bash

"$HOME/.bin/eww" open-many topbar-left topbar-right &

sleep 10
slack -u &
flameshot &
openrgb --startminimized --server &
discord --start-minimized --enable-features=UseOzonePlatform --ozone-platform=wayland &

sleep 3
openrgb -p Blue &
