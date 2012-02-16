#!/bin/bash -e

[ $# -eq 1 ] || exit 1

PARAM_FILE=$1

. "$PARAM_FILE"

for VAR in `grep -v '# *ignore' "$PARAM_FILE" | cut -s -d= -f1`; do
	echo "s|${VAR}|${!VAR}|g;"
done
