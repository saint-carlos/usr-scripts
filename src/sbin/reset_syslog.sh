#!/bin/bash

PROGRAM=`basename $0`
DESCRIPTION="reset the system log file"
PARAMS=""
OPTIONS="[-hk]"

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
while getopts kh option; do
    case $option in
        h) usage 0 ;;
        k) KEEP=true ;;
        \?) usage 1 ;;
    esac
done
shift `expr $OPTIND - 1`

old_file="MESSAGES_PLACEHOLDER"
new_file="${old_file}-`date +%y-%m-%d-%H-%M-%S`"

service rsyslog stop
$KEEP && return
rm ${old_file}-*
[ -e "$old_file" ] && mv "$old_file" "$new_file" && echo "message file saved to $new_file"
service rsyslog start
