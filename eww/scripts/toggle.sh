#!/bin/bash

case $1 in
"calendar")
  if eww windows | grep "calendar" | head -n1 | grep -q "\*"; then
    eww close calendar-left calendar-right
  else
    eww open-many calendar-left calendar-right
  fi
  ;;
*)
  echo "Invalid command"
  ;;
esac
