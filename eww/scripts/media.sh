#!/bin/bash

case $1 in
"metadata")
  path=""

  url=$(playerctl metadata mpris:artUrl)
  if [[ $url == "https://"* ]]; then
    ext="${url##*.}"

    rm -rf ~/.config/eww/thumb.*
    wget -q -O "$HOME/.config/eww/thumb.$ext" "$url"

    path="$HOME/.config/eww/thumb.$ext"
  elif [[ $url == "file://"* ]]; then
    path="${url:7}"
  fi

  echo "{ \"title\": \"$(playerctl metadata xesam:title)\", \"path\": \"$path\" }"
  ;;
*)
  echo "Invalid command"
  ;;
esac
