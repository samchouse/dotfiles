#!/usr/bin/env bash

INHIBITOR="${0/lock/inhibitor}"

case $1 in
"misc")
  case $2 in
  "on")
    openrgb -p Blue

    count=0
    while [[ $count -lt 3 ]] || ([[ $count -ge 3 ]] && hyprctl -j monitors | jq -r '.[].dpmsStatus' | grep -qx false); do
      ((count++))
      hyprctl dispatch dpms on
      sleep 2
    done
    ;;
  "off")
    openrgb -p Black
    hyprctl dispatch dpms off
    ;;
  esac
  ;;
"ss")
  grim -o DP-1 /tmp/hyprlock-2.png
  grim -o DP-2 /tmp/hyprlock-1.png
  grim -o VIRT-1 /tmp/hyprlock-3.png
  ;;
"work")
  case $2 in
  "ss")
    $0 ss
    ;;
  esac

  (
    hyprlock
    if ! grep -q "inactive" /tmp/inhibitor_status; then
      "$INHIBITOR" toggle true
    fi
  ) &
  ;;
"chat1")
LOG_FILE="/tmp/hypridle_input_log"

: > "$LOG_FILE"

sudo libinput debug-events | while read -r line; do
    now=$(date +"%H:%M:%S.%3N")

    if [[ "$line" == *"KEYBOARD_KEY"* ]]; then
        echo "$now keyboard" >> "$LOG_FILE"
    elif [[ "$line" == *"POINTER"* ]]; then
        echo "$now mouse" >> "$LOG_FILE"
    elif [[ "$line" == *"TOUCH"* ]]; then
        echo "$now touch" >> "$LOG_FILE"
    else
        continue
    fi

    # keep only last 5 events
    tail -n 5 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
done
  ;;
"chat")

LOG_FILE="/tmp/hypridle_input_log"

now=$(date +"%H:%M:%S.%3N")

output="Wake @ $now\n"

if [[ -f "$LOG_FILE" ]]; then
    while read -r line; do
        output+="$line\n"
    done < "$LOG_FILE"
else
    output+="no input history"
fi

echo "$output"
  ;;
*)
  if ! pgrep -x "hyprlock" >/dev/null; then
    playerctl --player playerctld pause || true

    i_status=$("$INHIBITOR" status)
    echo "$i_status" >/tmp/inhibitor_status
    if [ "$i_status" == "active" ]; then
      "$INHIBITOR" toggle true
    fi

    if [ "$1" == "full" ]; then
      $0 work ss &
    else
      $0 work
    fi
  fi
  ;;
esac
