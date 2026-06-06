#!/usr/bin/env bash

hyprctl -i 0 output create headless VIRT-1

sleep 1
ags run &

sleep 3
1password --silent &
discordcanary --start-minimized &
steam -nochatui -nofriendsui -silent -vgui &

~/.config/hypr/scripts/lock.sh full &

disown
