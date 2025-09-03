#!/usr/bin/env bash

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
  virt)
    active_workspace=$(hyprctl workspaces -j | jq -r '.[] | select(.id==10)')
    ;;
  *)
    echo "Invalid command"
    ;;
  esac

  get_workspaces_statuses() {
    workspaces=()
    for i in {1..9}; do
      active_id=$(echo "$active_workspace" | jq -r .id)
      monitor=$(hyprctl workspaces -j | jq -r ".[] | select(.id==$i) | .monitor")
      created=$(hyprctl workspaces | grep "workspace ID" | awk '{ print $3 }' | grep -q "$i" && echo true || echo false)
      workspaces+=("{ \"id\": \"$i\", \"created\": $created, \"mine\": $([ "$monitor" = "$(echo "$active_workspace" | jq -r .monitor)" ] && echo true || echo false), \"focused\": $([ "$active_id" -eq "$i" ] && echo true || echo false) }")
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
      fi

      get_workspaces_statuses
      ;;
    workspace*)
      new_id=${1//workspace>>/}
      workspace=$(hyprctl workspaces -j | jq -r ".[] | select(.id==$new_id)")

      if echo "$workspace" | grep -q "$monitor"; then
        active_workspace=$workspace
      fi

      get_workspaces_statuses
      ;;
    esac
  }

  get_workspaces_statuses
  socat -u "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do handle "$line"; done
  ;;
*)
  echo "Invalid command"
  ;;
esac
