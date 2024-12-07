#!/usr/bin/env bash

PIPE="/tmp/eww-media-$(
  echo $RANDOM | md5sum | head -c 10
  echo
)"

cleanup() {
  rm -f "$PIPE"
  pkill -P $$
}

trap cleanup SIGINT SIGTERM EXIT

case $1 in
"daemon")
  handler() {
    target=$1
    printed=false

    while true; do
      if playerctl --player playerctld status 2>&1 | grep -q Playing || [[ $2 == "false" ]]; then
        target=$(date -d '3 min' +%s)

        if [[ $printed == false ]]; then
          printed=true
          echo "$2"
        fi

        continue
      fi

      printed=false
      if [ "$(date +%s)" = "$target" ] || playerctl --list-all 2>&1 | grep -q "No players found"; then
        echo ""
        continue
      fi

      sleep 0.5
    done
  }

  handle() {
    kill "$PID" >>/dev/null 2>&1

    first=$(echo "$1" | cut -d' ' -f 1)
    second=$(echo "$1" | cut -d' ' -f 2-)

    handler "$first" "$second" &
    PID=$!
  }

  while read -r line <"$2"; do handle "$line"; done

  exit
  ;;
esac

case $2 in
"metadata")
  handle_global() {
    if [[ $1 == "skip" ]]; then
      return
    fi

    echo "$(date -d '3 min' +%s) $1" >"$PIPE"
  }

  mkfifo "$PIPE"
  $0 daemon "$PIPE" &

  while getopts "stp" opt; do
    case $opt in
    t)
      playerctl -F --player playerctld metadata xesam:title 2>/dev/null | while read -r line; do handle_global "$line"; done
      ;;
    s)
      playerctl -F --player playerctld status 2>/dev/null | while read -r line; do handle_global "$([[ $line == "Playing" ]] && echo true || [[ $line != "" ]] && echo false || echo skip)"; done
      ;;
    p)
      handle() {
        if [[ $1 == "https://"* ]]; then
          ext="${1##*.}"

          rm -rf ~/.config/eww/thumb.*
          wget -q -O "$HOME/.config/eww/thumb.$ext" "$1"

          echo "$HOME/.config/eww/thumb.$ext"
        elif [[ $1 == "file://"* ]]; then
          echo "${1:7}"
        fi
      }

      playerctl -F --player playerctld metadata mpris:artUrl 2>/dev/null | while read -r line; do handle_global "$(handle "$line")"; done
      ;;
    \?)
      echo "Invalid option -$OPTARG" >&2
      ;;
    esac
  done
  ;;
*)
  echo "Invalid command"
  ;;
esac

echo ""
