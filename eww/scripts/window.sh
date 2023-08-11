#!/bin/bash

format() {
	case "$@" in
	null | "") echo "Desktop" ;;
	firefox) echo "Mozilla Firefox" ;;
	org.kde.dolphin) echo "Dolphin" ;;
	"Code - Insiders" | "code-insiders-url-handler") echo "VSCode Insiders" ;;
	*) echo "${@^}" ;;
	esac
}

export -f format

format "$(hyprctl activewindow -j | jq --raw-output .class)"
socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | stdbuf -o0 awk -F '>>|,' '/^activewindow>>/{system("format " $2)}'
