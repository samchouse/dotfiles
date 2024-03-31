#!/bin/bash

case $1 in
toggle)
  if systemctl --user status wayland-idle-inhibitor | grep -q "Active: active"; then
    systemctl --user stop wayland-idle-inhibitor
    eww update inhibitor_enabled=false
  else
    systemctl --user start wayland-idle-inhibitor
    eww update inhibitor_enabled=true
  fi

  icon=$("$0" icon)
  eww update "inhibitor_icon=$icon"
  ;;
icon)
  if systemctl --user status wayland-idle-inhibitor | grep -q "Active: active"; then
    echo ""
  else
    echo ""
  fi
  ;;
*)
  echo "Invalid command"
  ;;
esac
