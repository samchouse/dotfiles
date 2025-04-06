#!/usr/bin/env bash

case $1 in
status)
  if systemctl --user status hypridle | grep -q "Active: active"; then
    echo "inactive"
  else
    echo "active"
  fi
  ;;
toggle)
  if [ "$("$0" status)" == "inactive" ]; then
    systemctl --user stop hypridle
    if [ -z "$2" ]; then
      eww update inhibitor_enabled=true
    fi
  else
    systemctl --user start hypridle
    if [ -z "$2" ]; then
      eww update inhibitor_enabled=false
    fi
  fi

  if [ -z "$2" ]; then
    icon=$("$0" icon)
    eww update "inhibitor_icon=$icon"
  fi
  ;;
icon)
  if [ "$("$0" status)" == "inactive" ]; then
    echo ""
  else
    echo ""
  fi
  ;;
*)
  echo "Invalid command"
  ;;
esac
