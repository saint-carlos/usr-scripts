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

[ $# -ge 2 ] || exit 1

PARAMS_FILE="$1"
INSTALL_SOURCE="$2"
shift 2

. "$PARAMS_FILE"
. "$(dirname $BASH_SOURCE)/common.sh"

for FILE; do
	DIR=${FILE%%/*}
	if [ $UID -ne 0 ] && [ $DIR = sbin ]; then
		continue
	fi
	if [[ $DIR =~ bin ]]; then
		MODE=755
	else
		MODE=644
	fi
	install -m $MODE -D $INSTALL_SOURCE/$FILE $CONFIG_VROOT/$FILE
done
