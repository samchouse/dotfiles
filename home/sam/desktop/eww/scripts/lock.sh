#!/usr/bin/env bash

INHIBITOR="${0/lock/inhibitor}"

case $1 in
"misc")
  case $2 in
  "on")
    echo on >/tmp/usb-power
    openrgb -p Blue
    while hyprctl -j monitors | jq -r '.[].dpmsStatus' | grep -qx false; do
      hyprctl dispatch dpms on
      sleep 0.1
    done
    ;;
  "off")
    echo off >/tmp/usb-power
    openrgb -p Black
    hyprctl dispatch dpms off
    ;;
  esac
  ;;
"ss")
  grim -o DP-1 /tmp/hyprlock-2.png
  grim -o DP-2 /tmp/hyprlock-1.png
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
    playerctl --player playerctld pause || true

    i_status=$("$INHIBITOR" status)
    echo "$i_status" >/tmp/inhibitor_status
    if [ "$i_status" == "active" ]; then
      "$INHIBITOR" toggle true
    fi
    systemctl --user status hypridle --no-pager

    if [ "$1" == "eww" ]; then
      $0 work ss &
    else
      $0 work
    fi
  fi
  ;;
esac
