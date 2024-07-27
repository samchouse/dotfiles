#!/bin/bash

case $1 in
"get-output")
  handle() {
    if [[ "$1" != "" ]] && ! echo "$1" | grep -q card; then
      return
    fi

    device=$(pactl list sinks short | awk '{ print $2 }' | awk -F '.' '{ print $NF }')
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
  }

  handle
  pactl subscribe | while read -r line; do handle "$line"; done
  ;;
"toggle-output")
  device=$(pactl list sinks short | awk '{ print $2 }' | awk -F '.' '{ print $NF }')
  case $device in
  "hdmi-stereo")
    $0 set-output headphones
    ;;
  "hdmi-stereo-extra1")
    $0 set-output speakers
    ;;
  *)
    echo "Unknown device: $device"
    ;;
  esac
  ;;
"set-output")
  card=$(pactl list sinks short | awk '{ print $2 }' | awk -F '.' '{$NF=""; sub(/\.$/, ""); print $0}' OFS='.' | sed 's/output/card/')
  case $2 in
  "speakers")
    pactl set-card-profile "$card" "output:hdmi-stereo"
    ;;
  "headphones")
    pactl set-card-profile "$card" "output:hdmi-stereo-extra1"
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
