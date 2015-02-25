#!/bin/bash -xe

[ $# -ge 2 ] || exit 1

PARAMS_FILE="$1"
INSTALL_SOURCE="$2"
shift 2

source "$PARAMS_FILE"
source "$(dirname $BASH_SOURCE)/common.sh"

mkdir "$CONFIG_VROOT"
git rev-parse HEAD > "$CONFIG_VROOT/version"

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
