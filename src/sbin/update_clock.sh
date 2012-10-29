#!/bin/sh

PROGRAM=`basename $0`
DESCRIPTION="update the system time"
OPTIONS="[-h]"

usage()
{
    echo "$PROGRAM - $DESCRIPTION"
    echo "usage:"
    echo "$PROGRAM $OPTIONS"
    echo
    echo $'-h\thelp: show this help message and exit.'
    echo
    echo "exit status is 0 if all arguments are OK, 1 if some arguments are bad."

    exit $1
}
while getopts h option; do
    case $option in
        h) usage 0 ;;
        \?) usage 1 ;;
    esac
done
shift `expr $OPTIND - 1`

TIME_SERVER=""
exit 0
ntpdate $TIME_SERVER
