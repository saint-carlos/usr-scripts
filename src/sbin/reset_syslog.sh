#!/bin/bash -p

PROGRAM=$(basename $0)
DESCRIPTION="reset the system log file"
PARAMS=""
OPTIONS="[-hk]"

set -o privileged

usage()
{
	[ $1 -ne 0 ] && exec >&2

	cat << EOF
$PROGRAM - $DESCRIPTION
usage:
$PROGRAM $OPTIONS $PARAMS

options:
-h	help: show this help message and exit.
-k	keep: do not truncate the current message file.

exit status:
0	all OK
1	bad arguments
EOF

    exit $1
}

KEEP=false
while getopts kh OPTION; do
	case $OPTION in
		h) usage 0 ;;
		k) KEEP=true ;;
		\?) usage 1 ;;
	esac
done
shift $((OPTIND - 1))

OLD_FILE="CONFIG_SYSLOG_FILE"
NEW_FILE="${OLD_FILE}-$(timestamp)"

service rsyslog stop
$KEEP && return
rm ${OLD_FILE}*
[ -e "$OLD_FILE" ] && mv "$OLD_FILE" "$NEW_FILE" && echo "message file saved to $NEW_FILE"
service rsyslog start
