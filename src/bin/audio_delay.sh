#!/bin/bash -x

INPUT=$1
DELAY=$2
OUTPUT=$3

[ -n "$INPUT" ] || exit 2
[ -n "$OUTPUT" ] || exit 2

if ((DELAY >= 0)); then
	MAP0=0
	MAP1=1
else
	MAP0=1
	MAP1=0
fi
avconv \
	-i $INPUT -itsoffset $DELAY \
	-i $INPUT \
	-c:v copy -c:a copy \
	-map "0:$MAP0" \
	-map "1:$MAP1" \
	$OUTPUT
