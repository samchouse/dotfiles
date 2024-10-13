#!/usr/bin/env bash

SPEAKERS="output:hdmi-stereo"
HEADPHONES="output:hdmi-stereo-extra1"

get_device() {
  pw-cli ls Device | awk '/id [0-9]+, type/ {id_line = $0} /device.name = "alsa_card.pci-0000_01_00.1"/ {print id_line}' | grep -oP "id \d*" | sed 's/id //'
}

get_output() {
  output=$(wpctl status -n | grep -oP "(${HEADPHONES/output:/})|(${SPEAKERS/output:/})")
  echo "output:$output"
}

get_index() {
  line=$(pw-cli e "$(get_device)" EnumProfile | grep -nP "\"$1\"\$" | cut -d':' -f1)
  pw-cli e "$(get_device)" EnumProfile | head -n"$(("$line" - 2))" | tail -n1 | grep -oP "\d+"
}

while getopts "igt" opt; do
  case $opt in
  i)
    prev=""
    handle() {
      if [[ "$1" != "" ]] && [[ $1 -eq 0 ]]; then
        return
      fi

      raw_volume=$(echo "$(wpctl get-volume @DEFAULT_SINK@ | grep -oP "[\d|.]*")" 100 | awk '{printf "%0.0f\n",$1*$2}')
      volume=${raw_volume/\./}
      if [ "$volume" -eq 0 ]; then
        icon=""
      elif [ "$volume" -lt 50 ]; then
        icon=""
      else
        icon=""
      fi

      if wpctl get-volume @DEFAULT_SINK@ | grep -q "[MUTED]"; then
        icon=""
      fi

      curr="{ \"icon\": \"$icon\", \"volume\": \"$volume\" }"
      if [[ "$curr" != "$prev" ]]; then
        prev=$curr
        echo "$curr"
      fi
    }

    pw-dump -m --no-colors | jq --unbuffered 'del(.[] | select(.type != "PipeWire:Interface:Device")) | length' | while read -r line; do handle line; done
    ;;
  g)
    prev=""
    handle() {
      if [[ "$1" != "" ]] && [[ $1 -eq 0 ]]; then
        return
      fi

      curr=""
      output=$(get_output)
      if [[ "$output" == "$SPEAKERS" ]]; then
        curr="speakers"
      elif [[ "$output" == "$HEADPHONES" ]]; then
        curr="headphones"
      fi

      if [[ "$curr" != "$prev" ]]; then
        prev=$curr
        echo "$curr"
      fi
    }

    pw-dump -m --no-colors | jq --unbuffered 'del(.[] | select(.type != "PipeWire:Interface:Node")) | length' | while read -r line; do handle line; done
    ;;
  t)
    output=$(get_output)
    if [[ "$output" == "$SPEAKERS" ]]; then
      wpctl set-profile "$(get_device)" "$(get_index $HEADPHONES)"
    elif [[ "$output" == "$HEADPHONES" ]]; then
      wpctl set-profile "$(get_device)" "$(get_index $SPEAKERS)"
    fi
    ;;
  \?)
    echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done
