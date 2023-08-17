#!/bin/bash

"$HOME/.bin/eww" open-many topbar-left topbar-right &

sleep 10
flameshot >> /dev/null 2>&1 &
openrgb --startminimized --server >> /dev/null 2>&1 &
discord --start-minimized --enable-features=UseOzonePlatform --ozone-platform=wayland >> /dev/null 2>&1 &
slack --enable-features=UseOzonePlatform --enable-features=WebRTCPipeWireCapturer --enable-features=WaylandWindowDecorations --ozone-platform=wayland -u >> /dev/null 2>&1 &

sleep 3
openrgb -p Blue >> /dev/null 2>&1 &
