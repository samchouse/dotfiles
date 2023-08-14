#!/bin/bash

"$HOME/.bin/eww" open-many topbar-left topbar-right &

sleep 10
flameshot &
openrgb --startminimized --server &
discord --start-minimized --enable-features=UseOzonePlatform --ozone-platform=wayland &
slack --enable-features=UseOzonePlatform --enable-features=WebRTCPipeWireCapturer --enable-features=WaylandWindowDecorations --ozone-platform=wayland -u &

sleep 3
openrgb -p Blue &
