#!/bin/bash

while getopts "mi" opt; do
  case $opt in
  i)
    handle() {
      if [[ "$1" != "" ]] && ! echo "$1" | grep -q sink; then
        return
      fi

      volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP "[\d]*%" | head -n1 | sed 's/%//')
      if [ "$volume" -eq 0 ]; then
        icon=""
      elif [ "$volume" -lt 50 ]; then
        icon=""
      else
        icon=""
      fi

      muted=$(pactl get-sink-mute @DEFAULT_SINK@ | sed 's/Mute: //')
      if [ "$muted" = "yes" ]; then
        icon=""
      fi

      echo "{ \"icon\": \"$icon\", \"volume\": \"$volume\" }"
    }

    handle
    pactl subscribe | while read -r line; do handle "$line"; done
    ;;
  m)
    volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP "[\d]*%" | head -n1 | sed 's/%//')
    prev_volume=$(~/.bin/eww get previous_volume)
    if [ "$volume" -eq 0 ]; then
      pactl set-sink-volume @DEFAULT_SINK@ "$prev_volume%"
    else
      pactl set-sink-volume @DEFAULT_SINK@ 0%
      ~/.bin/eww update "previous_volume=$volume"
    fi
    ;;
  \?)
    echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done
