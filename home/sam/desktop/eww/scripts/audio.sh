#!/usr/bin/env bash

SPEAKERS="alsa_output.pci-0000_01_00.1.hdmi-stereo"
HEADPHONES="bluez_output.BC_87_FA_46_25_55.1"

get_output() {
  wpctl status -n | grep -oP "\*.+($SPEAKERS|$HEADPHONES)" | sed -E "s/.+($SPEAKERS|$HEADPHONES)/\1/"
}

get_id() {
  wpctl status -n | grep -oP "\d+\.\s$1" | sed -E "s/\s|$SPEAKERS|$HEADPHONES|\.//g"
}

while getopts "igt" opt; do
  case $opt in
  i)
    prev=""
    handle() {
      if [[ $1 != "" ]] && [[ $1 -eq 0 ]]; then
        return
      fi

      raw_volume=$(echo "$(wpctl get-volume @DEFAULT_SINK@ | grep -oP "[\d|.]*")" 100 | awk '{printf "%0.0f\n",$1*$2}')
      volume=${raw_volume/\./}
      if [ "$volume" -eq 0 ]; then
        icon=""
      elif [ "$volume" -lt 50 ]; then
        icon=""
      else
        icon=""
      fi

      if wpctl get-volume @DEFAULT_SINK@ | grep -q "[MUTED]"; then
        icon=""
      fi

      curr="{ \"icon\": \"$icon\", \"volume\": \"$volume\" }"
      if [[ $curr != "$prev" ]]; then
        prev=$curr
        echo "$curr"
      fi
    }

    pw-dump -m --no-colors | jq --unbuffered 'del(.[] | select(.type != "PipeWire:Interface:Node")) | length' | while read -r line; do handle "$line"; done
    ;;
  g)
    prev=""
    handle() {
      if [[ $1 != "" ]] && [[ $1 -eq 0 ]]; then
        return
      fi

      curr=""
      output=$(get_output)
      if [[ $output == "$SPEAKERS" ]]; then
        curr="speakers"
      elif [[ $output == "$HEADPHONES" ]]; then
        curr="headphones"
      fi

      if [[ $curr != "$prev" ]]; then
        prev=$curr
        echo "$curr"
      fi
    }

    pw-dump -m --no-colors | jq --unbuffered 'del(.[] | select(.type != "PipeWire:Interface:Node")) | length' | while read -r line; do handle "$line"; done
    ;;
  t)
    output=$(get_output)
    if [[ $output == "$SPEAKERS" ]]; then
      wpctl set-default "$(get_id "$HEADPHONES")"
    elif [[ $output == "$HEADPHONES" ]]; then
      wpctl set-default "$(get_id "$SPEAKERS")"
    fi
    ;;
  \?)
    echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done
