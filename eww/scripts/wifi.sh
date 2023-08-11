#!/bin/bash

strength=$(iwctl station wlan0 show | grep -w RSSI | awk '{ print $2 }')

if [ "$strength" -ge -55 ]; then
		echo ""
elif [ "$strength" -ge -63 ]; then
		echo ""
elif [ "$strength" -ge -70 ]; then
		echo ""
elif [ "$strength" -ge -75 ]; then
		echo ""
else
		echo ""
fi
