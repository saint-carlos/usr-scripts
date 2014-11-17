#!/bin/bash

PROGRAM=$(basename $0)
DESCRIPTION="update the system time"
OPTIONS="[-h]"

usage()
{
	[ $1 -ne 0 ] && exec >&2

	cat << EOF
$PROGRAM - $DESCRIPTION
usage:
$PROGRAM $OPTIONS

options:
-h	help: show this help message and exit.

exit status:
0	all OK
1	bad arguments
EOF

    exit $1
}

while getopts h OPTION; do
	case $OPTION in
		h) usage 0 ;;
		\?) usage 1 ;;
	esac
done
shift $((OPTIND - 1))

TIME_SERVER=""
exit 0
ntpdate $TIME_SERVER
