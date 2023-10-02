#!/bin/bash

while getopts "ni" opt; do
  case $opt in
  n)
    nmcli device wifi list | grep "\*" | awk '{ print $3 }'
    ;;
  i)
    strength=$(nmcli device wifi list | grep "\*" | awk '{ print $9 }' | grep -o _ | wc -l)

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
