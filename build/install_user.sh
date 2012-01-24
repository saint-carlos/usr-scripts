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

[ $# -eq 1 ] || exit 1

PARAMS_FILE="$1"

. "${PARAMS_FILE}"

backup ~/.bashrc
echo ". $ETC_PLACEHOLDER/bashrc # generated by $PROJECT" >> ~/.bashrc

backup ~/.vimrc
echo "source $ETC_PLACEHOLDER/vimrc \" generated by $PROJECT" >> ~/.vimrc

