#!/usr/bin/env bash

eww open-many topbar-left topbar-right >>/dev/null 2>&1 &

sleep 3
openrgb --startminimized --server >>/dev/null 2>&1 &
discordcanary --start-minimized >>/dev/null 2>&1 &
1password --silent >>/dev/null 2>&1 &

sleep 1
openrgb -p Blue >>/dev/null 2>&1 &
LIBGL_ALWAYS_SOFTWARE=1 xwaylandvideobridge >>/dev/null 2>&1 &

sleep 3
steam -nochatui -nofriendsui -silent -vgui >>/dev/null 2>&1 &

disown
