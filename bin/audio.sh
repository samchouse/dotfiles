#!/bin/bash

case $1 in
"get-output")
  device=$(pactl list sinks | grep "device.profile.name" | sed 's/device.profile.name = "//' | sed 's/"//' | xargs)
  case $device in
  "hdmi-stereo")
    echo "speakers"
    ;;
  "hdmi-stereo-extra1")
    echo "headphones"
    ;;
  *)
    echo "unknown"
    ;;
  esac
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