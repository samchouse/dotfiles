#!/bin/bash

while getopts "ni" opt; do
  case $opt in
  n)
    nmcli device wifi list | grep -P "^\*" | awk '{ print $3 }'
    ;;
  i)
    strength=$(nmcli device wifi list | grep -P "^\*" | awk '{ print $9 }' | grep -o "\*" | wc -l)

    if [[ $strength -eq 0 ]]; then
      echo ""
    elif [[ $strength -eq 1 ]]; then
      echo ""
    elif [[ $strength -eq 2 ]]; then
      echo ""
    elif [[ $strength -eq 3 ]]; then
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
