#!/bin/bash

case $1 in
toggle)
  if systemctl --user status hypridle | grep -q "Active: active"; then
    systemctl --user stop hypridle
    eww update inhibitor_enabled=true
  else
    systemctl --user start hypridle
    eww update inhibitor_enabled=false
  fi

  icon=$("$0" icon)
  eww update "inhibitor_icon=$icon"
  ;;
icon)
  if systemctl --user status hypridle | grep -q "Active: active"; then
    echo ""
  else
    echo ""
  fi
  ;;
*)
  echo "Invalid command"
  ;;
esac
