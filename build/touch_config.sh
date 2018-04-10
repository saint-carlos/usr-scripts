#!/bin/bash

set -xv
set -eu

CONFIG_FILE="$1"
DEFAULT_CONFIG_FILE="$2"
ALL_CONFIG_VARS="$3"
TMP_CFG="$4"

if [ -d "$CONFIG_FILE" ]; then
	exit 1
elif [ -s "$CONFIG_FILE" ]; then
	# add missing
	CURRENT_CONFIG_VARS="$TMP_CFG/config_vars.current.txt"
	cut -d= -f1 "$CONFIG_FILE" | sort > "$CURRENT_CONFIG_VARS"
	comm -23 "$ALL_CONFIG_VARS" "$CURRENT_CONFIG_VARS" \
		| xargs -L 1 -I @ grep --extended-regexp '^@\+?=' "$DEFAULT_CONFIG_FILE" \
		| sort \
		> "$TMP_CFG/config.preliminary"
	grep '\$$.*CONFIG' "$TMP_CFG/config.preliminary" \
		> "$TMP_CFG/config.dependent" || true
	comm -23 "$TMP_CFG/config.preliminary" "$TMP_CFG/config.dependent" \
		> "$TMP_CFG/config.tmp"
	echo "# configuration automatically added, see $DEFAULT_CONFIG_FILE" \
		>> "$CONFIG_FILE"
	cat "$TMP_CFG/config.tmp" "$TMP_CFG/config.dependent" >> "$CONFIG_FILE"
else
	cp "$DEFAULT_CONFIG_FILE" "$CONFIG_FILE"
fi
