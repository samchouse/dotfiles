#!/usr/bin/env bash

case $1 in
"calendar")
  if eww active-windows | grep -q "calendar"; then
    eww close calendar-left calendar-right
  else
    eww open-many calendar-left calendar-right
  fi
  ;;
*)
  echo "Invalid command"
  ;;
esac
