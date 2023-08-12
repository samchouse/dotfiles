#!/bin/bash

case $1 in
"toggle-output")
	device=$(pactl list sinks | grep "device.profile.name" | sed 's/device.profile.name = "//' | sed 's/"//' | xargs)
	case $device in
	"hdmi-stereo")
		$0 set-output speakers
		;;
	"hdmi-stereo-extra1")
		$0 set-output headphones
		;;
	*)
		echo "Unknown device: $device"
		;;
	esac
	;;
"set-output")
	case $2 in
	"headphones")
		pactl set-card-profile alsa_card.pci-0000_01_00.1 output:hdmi-stereo
		;;
	"speakers")
		pactl set-card-profile alsa_card.pci-0000_01_00.1 output:hdmi-stereo-extra1
		;;
	*)
		echo "Usage: $0 set-output <headphones|speakers>"
		;;
	esac
	;;
*)
	echo "Usage:
$0 toggle-output
$0 set-output <headphones|speakers>"
	;;
esac
