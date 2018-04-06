#!/bin/bash

set -xe

[ $# -eq 2 ] || exit 1
FUNCTION="$1"
CONFIG_FILE="$2"

source "$(dirname $BASH_SOURCE)/common.sh" "$CONFIG_FILE"

install()
{
	[ $UID -eq 0 ] || return 1

	# we can't link it because rsyslog is stupid
	safe_replace /etc/rsyslog.conf \
		cp "$CONFIG_ETC/rsyslog.conf" @@@
}

uninstall()
{
	[ $UID -eq 0 ] || return 1

	restore_backup /etc/rsyslog.conf
}

"$FUNCTION"
