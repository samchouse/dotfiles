#!/bin/bash

case $1 in
"toggle")
  playerctl --player playerctld play-pause

  isPlaying=$(~/.bin/eww get media_isplaying)
  if [[ $isPlaying == "true" ]]; then
    isPlaying="false"
  else
    isPlaying="true"
  fi

  ~/.bin/eww update "media_isplaying=$isPlaying"
  exit
  ;;
esac

case $2 in
"metadata")
  while getopts "stp" opt; do
    case $opt in
    t)
      playerctl -F --player playerctld metadata xesam:title 2>/dev/null
      ;;
    s)
      playerctl -F --player playerctld status 2>/dev/null | while read -r line; do [[ $line == "Playing" ]] && echo true || echo false; done
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

      playerctl -F --player playerctld metadata mpris:artUrl 2>/dev/null | while read -r line; do handle "$line"; done
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
