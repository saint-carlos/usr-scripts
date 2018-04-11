#!/bin/bash

if xrandr -q &> /dev/null; then
	xrandr -q \
		| grep -w connected \
		| wc -l
elif which nvidia-xconfig &> /dev/null; then
	nvidia-xconfig --query-gpu-info \
		| grep 'Display Devices:' \
		| awk 'BEGIN { r = 0 } { r += $NF } END { print r }'
else
	echo 1
fi
