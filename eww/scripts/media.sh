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
      playerctl --player playerctld metadata xesam:title 2>/dev/null
      ;;
    s)
      status=$(playerctl --player playerctld status 2>/dev/null)
      if [[ $status == "Playing" ]]; then
        echo "true"
        exit
      fi

      echo "false"
      ;;
    p)
      url=$(playerctl --player playerctld metadata mpris:artUrl 2>/dev/null)
      if [[ $url == "https://"* ]]; then
        ext="${url##*.}"

        rm -rf ~/.config/eww/thumb.*
        wget -q -O "$HOME/.config/eww/thumb.$ext" "$url"

        echo "$HOME/.config/eww/thumb.$ext"
      elif [[ $url == "file://"* ]]; then
        echo "${url:7}"
      fi
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
