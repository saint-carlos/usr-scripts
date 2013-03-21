#!/bin/bash -xe

install_dir()
{
	DIRNAME="$1"
	MODE="$2"
	PLACEHOLDER="$3"
	mkdir -p "$PLACEHOLDER"
	cp "$INSTALL_SOURCE/$DIRNAME"/* "$PLACEHOLDER"
	chmod "$MODE" "$PLACEHOLDER"/*

}

[ $# -eq 2 ] || exit 1

PARAMS_FILE="$1"
INSTALL_SOURCE="$2"

. "$PARAMS_FILE"
. "$(dirname $BASH_SOURCE)/common.sh"

install_dir etc 0644 "$ETC_PLACEHOLDER"
install_dir bin 0755 "$BIN_PLACEHOLDER"
if [ $UID -eq 0 ]; then
	install_dir sbin 0755 "$SBIN_PLACEHOLDER"
fi
