#!/bin/bash -xe

[ $# -eq 2 ] || exit 1

PARAMS_FILE="$1"
INSTALL_SOURCE="$2"

. "${PARAMS_FILE}"

mkdir -p "$ETC_PLACEHOLDER" && cp $INSTALL_SOURCE/etc/* $ETC_PLACEHOLDER && chmod 0644 $ETC_PLACEHOLDER/*
mkdir -p "$BIN_PLACEHOLDER" && cp $INSTALL_SOURCE/bin/* $BIN_PLACEHOLDER && chmod 0755 $BIN_PLACEHOLDER/*
if [ `id -u` -eq 0 ]; then
	mkdir -p "$SBIN_PLACEHOLDER" && cp $INSTALL_SOURCE/sbin/* $SBIN_PLACEHOLDER && chmod 0755 $SBIN_PLACEHOLDER/*
fi

