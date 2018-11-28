#!/bin/bash

set -u

if false; then
i=1
MAX=0
tac | {
declare -A TIME
while read LINE; do
	[ -n "$LINE" ] || continue
	((TIME[$LINE] == 0)) && ((TIME[$LINE]=i))
	if ((TIME[$LINE] > MAX)); then
		((MAX=TIME[$LINE]))
		MAXI="$LINE"
	fi
	((i++))
done
echo $MAXI
}
fi

TIME=0
declare -A TIMESTAMP
while read LINE; do
	TIMESTAMP["$LINE"]=$TIME
	((TIME++))
done
FILE=/tmp/lru
declare -a TIME_TO_LINE
for LINE in "${!TIMESTAMP[@]}"; do
	TIME=${TIMESTAMP["$LINE"]}
	TIME_TO_LINE["$TIME"]="$LINE"
done
REVTIME=""
for TIME in ${!TIME_TO_LINE[@]}; do
	REVTIME="$TIME $REVTIME"
done
for TIME in $REVTIME; do
	echo ${TIME_TO_LINE[TIME]}
done
