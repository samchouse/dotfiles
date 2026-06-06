#!/usr/bin/env bash

INHIBITOR="${0/lock/inhibitor}"

case $1 in
"misc")
  case $2 in
  "on")
    count=0
    while [[ $count -lt 3 ]] || ([[ $count -ge 3 ]] && hyprctl -j monitors | jq -r '.[].dpmsStatus' | grep -qx false); do
      ((count++))
      hyprctl dispatch dpms on
      sleep 2
    done
    ;;
  "off")
    hyprctl dispatch dpms off
    ;;
  esac
  ;;
"ss")
  grim -o VIRT-1 /tmp/hyprlock-3.png
  ;;
"work")
  case $2 in
  "ss")
    $0 ss
    ;;
  esac

  (
    hyprlock
    if ! grep -q "inactive" /tmp/inhibitor_status; then
      "$INHIBITOR" toggle true
    fi
  ) &
  ;;
*)
  if ! pgrep -x "hyprlock" >/dev/null; then
    i_status=$("$INHIBITOR" status)
    echo "$i_status" >/tmp/inhibitor_status
    if [ "$i_status" == "active" ]; then
      "$INHIBITOR" toggle true
    fi

    if [ "$1" == "full" ]; then
      $0 work ss &
    else
      $0 work
    fi
  fi
  ;;
esac
