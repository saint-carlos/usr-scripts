#!/bin/bash -e

make_sed_commands()
{
	for VAR in `cut -s -d= -f1 "$PARAM_FILE"`; do
		echo "s|${VAR}|${!VAR}|g;"
	done
}

[ $# -eq 3 ] || exit 1

PARAM_FILE=$1
SRC=$2
TGT=$3

. "$PARAM_FILE"

cp -r $SRC/* $TGT
SED_COMMANDS=`make_sed_commands "$PARAM_FILE"`
sed -i "$SED_COMMANDS" $TGT/bin/* $TGT/sbin/* $TGT/etc/*

