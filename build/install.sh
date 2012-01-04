#!/bin/bash -xe

backup()
{
	FILE="$1"
	if [ -f "${FILE}.bak" ]; then
		echo "cannot backup ${FILE}" >&2
		exit 2
	fi
	if [ -f "$FILE" ]; then
		cp "$FILE" "${FILE}.bak"
	fi
}

[ $# -eq 2 ] || exit 1

PARAMS_FILE="$1"
INSTALL_SOURCE="$2"

. "${PARAMS_FILE}"

mkdir -p "$ETC_PLACEHOLDER"
mkdir -p "$BIN_PLACEHOLDER"
mkdir -p "$SBIN_PLACEHOLDER"
cp tgt/etc/* $ETC_PLACEHOLDER
cp tgt/bin/* $BIN_PLACEHOLDER
cp tgt/sbin/* $SBIN_PLACEHOLDER

backup ~/.bashrc
echo ". $ETC_PLACEHOLDER/bashrc" >> ~/.bashrc

backup ~/.vimrc
echo "source $ETC_PLACEHOLDER/vimrc" >> ~/.vimrc

