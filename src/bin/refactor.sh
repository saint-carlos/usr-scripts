#!/bin/bash

set -eu

PROGRAM=$(basename $0)
FROM="$1"
TO="$2"
shift 2

EXP="#define $1 $2"
TOKEN="//~${PROGRAM}~~~"


for FILE; do
	TEMP="/tmp/${PROGRAM}.E"
	cat <(echo "$EXP") <(sed "s@#@${TOKEN}@" "$FILE") \
		| cpp -P -C \
		| sed "s@${TOKEN}@#" > "${TEMP}"
	mv "$FILE" "${FILE}.bak"
	mv "$TEMP" "$FILE"
done
