#!/bin/bash

case $1 in
"get-output")
  handle() {
    if [[ "$1" != "" ]] && ! echo "$1" | grep -q card; then
      return
    fi

    device=$(pactl list sinks | grep "alsa.id" | sed 's/alsa.id = "//' | sed 's/"//' | xargs)
    case $device in
    "HDMI 0")
      echo "speakers"
      ;;
    "HDMI 1")
      echo "headphones"
      ;;
    *)
      echo "unknown"
      ;;
    esac
  }

  handle
  pactl subscribe | while read -r line; do handle "$line"; done
  ;;
"toggle-output")
  device=$(pactl list sinks | grep "alsa.id" | sed 's/alsa.id = "//' | sed 's/"//' | xargs)
  case $device in
  "HDMI 0")
    $0 set-output headphones
    ;;
  "HDMI 1")
    $0 set-output speakers
    ;;
  *)
    echo "Unknown device: $device"
    ;;
  esac
  ;;
"set-output")
  sink=$(pactl list sinks | grep -E "^\s*device.name" | sed 's/device.name = "//' | sed 's/"//' | xargs)
  case $2 in
  "headphones")
    output=$(pactl list cards | grep "output:hdmi-stereo" | grep "(HDMI 2)" | xargs | grep -oP "output:hdmi-stereo(-extra\d)*")
    pactl set-card-profile "$sink" "$output"
    ;;
  "speakers")
    output=$(pactl list cards | grep "output:hdmi-stereo" | grep "(HDMI)" | xargs | grep -oP "output:hdmi-stereo(-extra\d)*")
    pactl set-card-profile "$sink" "$output"
    ;;
  *)
    echo "Usage: $0 set-output <headphones|speakers>"
    ;;
  esac
  ;;
*)
  echo "Usage:
$0 toggle-output
$0 set-output <headphones|speakers>"
  ;;
esac
