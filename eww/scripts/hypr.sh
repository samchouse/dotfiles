#!/bin/bash

join_by() {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

case $1 in
workspaces)
  case $2 in
  left)
    active_workspace=$(hyprctl workspaces -j | jq -r '.[] | select(.id==1)')
    ;;
  right)
    active_workspace=$(hyprctl workspaces -j | jq -r '.[] | select(.id==2)')
    ;;
  *)
    echo "Invalid command"
    ;;
  esac

  get_workspaces_statuses() {
    workspaces=()
    for i in {1..9}; do
      active_id=$(echo "$active_workspace" | jq -r .id)
      created=$(hyprctl workspaces | grep "workspace ID" | awk '{ print $3 }' | grep -q "$i" && echo true || echo false)
      workspaces+=("{ \"id\": \"$i\", \"created\": $created, \"focused\": $([ "$active_id" -eq "$i" ] && echo true || echo false) }")
    done

    echo "[ $(join_by , "${workspaces[@]}") ]"
  }

  handle() {
    monitor=$(echo "$active_workspace" | jq -r .monitor)

    case $1 in
    focusedmon*)
      if echo "$1" | grep -q "$monitor"; then
        # shellcheck disable=SC2001
        new_id=$(echo "$1" | sed "s|.*>>$monitor,||")
        active_workspace=$(hyprctl workspaces -j | jq -r ".[] | select(.id==$new_id)")
        get_workspaces_statuses
      fi
      ;;
    workspace*)
      new_id=${1//workspace>>/}
      workspace=$(hyprctl workspaces -j | jq -r ".[] | select(.id==$new_id)")

      if echo "$workspace" | grep -q "$monitor"; then
        active_workspace=$workspace
        get_workspaces_statuses
      fi
      ;;
    esac
  }

  get_workspaces_statuses
  socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do handle "$line"; done
  ;;
*)
  echo "Invalid command"
  ;;
esac
