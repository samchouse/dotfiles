#!/usr/bin/env bash

first_date=""
while :; do
  count=$(wpctl status | sed -n '/Streams:/,$p' | grep Chromium | wc -l)

  if [[ $count -eq 1 ]]; then
    if [[ $first_date == "" ]]; then
      first_date=$(date +%s)
    fi

    elapsed=$(($(date +%s) - first_date))
    if [[ $elapsed -gt 30 ]]; then
      pw-cli d "$(wpctl status | sed -n '/Streams:/,$p' | grep Chromium | awk '$1=$1' | grep -E "Chromium$" | grep -oE "[0-9]+")"
      first_date=""
    fi
  else
    first_date=""
  fi

  sleep 3
done
