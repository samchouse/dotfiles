#!/bin/bash

eww open-many topbar-left topbar-right >>/dev/null 2>&1 &

sleep 3
openrgb --startminimized --server >>/dev/null 2>&1 &
vesktop --start-minimized --enable-features=UseOzonePlatform --ozone-platform=wayland >>/dev/null 2>&1 &
slack --enable-features=UseOzonePlatform,WaylandWindowDecorations --enable-features=WebRTCPipeWireCapturer --ozone-platform=wayland -u >>/dev/null 2>&1 &
1password --enable-features=UseOzonePlatform --ozone-platform=wayland --silent >>/dev/null 2>&1 &

sleep 1
openrgb -p Blue >>/dev/null 2>&1 &
LIBGL_ALWAYS_SOFTWARE=1 xwaylandvideobridge >>/dev/null 2>&1 &

disown
