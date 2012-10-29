#!/bin/bash

make_sed_commands()
{
	grep = "$PARAM_FILE" | sed 's/^/s|/; s/=/|/; s/$/|;/'
}

[ $# -eq 3 ] || exit 1

PARAM_FILE=$1
SRC=$2
TGT=$3

cp -r $SRC/* $TGT
SED_COMMANDS=`make_sed_commands "$PARAM_FILE"`
sed -i "$SED_COMMANDS" $TGT/bin/* $TGT/sbin/* $TGT/etc/*

