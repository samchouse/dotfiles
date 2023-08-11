#!/bin/bash

while getopts "gsmi" opt; do
	case $opt in
	g)
		pactl get-sink-volume @DEFAULT_SINK@ | grep -oP "[\d]*%" | head -n1 | sed 's/%//'
		;;
	s)
		pactl set-sink-volume @DEFAULT_SINK@ "$2%"
		~/.bin/eww update "volume_percentage=$2"
		;;
	m)
		VOLUME=$(~/.bin/eww get volume_percentage)
		PREV_VOLUME=$(~/.bin/eww get previous_volume)
		if [ "$VOLUME" -eq 0 ]; then
			pactl set-sink-volume @DEFAULT_SINK@ "$PREV_VOLUME%"
			~/.bin/eww update "volume_percentage=$PREV_VOLUME"
		else
			pactl set-sink-volume @DEFAULT_SINK@ 0%
			~/.bin/eww update "volume_percentage=0"
			~/.bin/eww update "previous_volume=$VOLUME"
		fi
		;;
	i)
		VOLUME=$(~/.bin/eww get volume_percentage)
		if [ "$VOLUME" -eq 0 ]; then
			echo 
		elif [ "$VOLUME" -le 40 ]; then
			echo 
		else
			echo 
		fi
		;;
	\?)
		echo "Invalid option -$OPTARG" >&2
		;;
	esac
done
