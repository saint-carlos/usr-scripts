#!/bin/bash -e

[ $# -eq 1 ] || exit 1

PARAM_FILE=$1

source "$PARAM_FILE"
source "$(dirname $BASH_SOURCE)/common.sh"

for VAR in `declare +aAF | grep '^CONFIG_[0-9A-Z_]*=' | cut -s -d= -f1`; do
	echo "s|\<${VAR}\>|${!VAR}|g;"
done
