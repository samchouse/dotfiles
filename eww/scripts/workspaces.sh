#!/bin/bash

join_by() {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

case $1 in
status)
  workspaces=()
  for i in {1..9}; do
    created=$(hyprctl workspaces | grep "workspace ID" | awk '{ print $3 }' | grep -q "$i" && echo true || echo false)
    focused=$(hyprctl activeworkspace | grep "workspace ID" | awk '{ print $3 }' | grep -q "$i" && echo true || echo false)
    workspaces+=("{ \"id\": \"$i\", \"created\": $created, \"focused\": $focused }")
  done

  echo "[ $(join_by , "${workspaces[@]}") ]"
  ;;
*)
  echo "Invalid command"
  ;;
esac
