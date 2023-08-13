#!/bin/bash

NAME=$(ip -o l | awk -F '[ :]' '/f0:b6:1e:93:7f:10/{ print $3 }')

while getopts "ni" opt; do
  case $opt in
  n)
    iwctl station "$NAME" show | grep "Connected network" | awk '{ print $3 }'
    ;;
  i)
    strength=$(iwctl station "$NAME" show | grep -w RSSI | awk '{ print $2 }')

    if [ "$strength" -ge -55 ]; then
      echo ""
    elif [ "$strength" -ge -63 ]; then
      echo ""
    elif [ "$strength" -ge -70 ]; then
      echo ""
    elif [ "$strength" -ge -81 ]; then
      echo ""
    else
      echo ""
    fi
    ;;
  \?)
    echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done
