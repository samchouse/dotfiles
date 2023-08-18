#!/bin/bash

case $1 in
"get-output")
  handle() {
    if [[ "$1" != "" ]] && ! echo "$1" | grep -q card; then
      return
    fi

    device=$(pactl list sinks | grep "device.profile.name" | sed 's/device.profile.name = "//' | sed 's/"//' | xargs)
    case $device in
    "hdmi-stereo")
      echo "headphones"
      ;;
    "hdmi-stereo-extra1")
      echo "speakers"
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
  device=$(pactl list sinks | grep "device.profile.name" | sed 's/device.profile.name = "//' | sed 's/"//' | xargs)
  case $device in
  "hdmi-stereo")
    $0 set-output speakers
    ;;
  "hdmi-stereo-extra1")
    $0 set-output headphones
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
    pactl set-card-profile "$sink" output:hdmi-stereo
    ;;
  "speakers")
    pactl set-card-profile "$sink" output:hdmi-stereo-extra1
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
