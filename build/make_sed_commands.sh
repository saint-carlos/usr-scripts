#!/bin/bash -e

[ $# -eq 1 ] || exit 1

source "$(dirname $BASH_SOURCE)/config_allvars.sh" "$1"

for VAR in $(declare +aAF | grep '^CONFIG_[0-9A-Z_]*=' | cut -d= -f1 -s); do
	echo "s|\<${VAR}\>|${!VAR}|g;"
done
