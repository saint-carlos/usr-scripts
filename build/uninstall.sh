#!/bin/bash -xe

remove_line()
{
	SEARCH_TERM="$1"
	FILE="$2"
	TMP_FILE=$(make_temp_file $FILE)
	test -f "$FILE" || return 0
	if grep -v "$SEARCH_TERM" "$FILE" > "$TMP_FILE"; then
		mv "$TMP_FILE" "$FILE"
	else
		rm -f "$FILE" "$TMP_FILE"
	fi
}

restore_backup()
{
	FILE=$1
	BACKUP_FILE=$(make_backup_file $FILE)
	rm -f "$FILE"
	if [ -f "$BACKUP_FILE" ]; then
		mv "$BACKUP_FILE" "$FILE"
	fi
}


[ $# -eq 1 ] || exit 1

PARAMS_FILE="$1"
source "${PARAMS_FILE}"
source "$(dirname $BASH_SOURCE)/common.sh"

remove_line "generated by $PROJECT" ~/.bashrc
remove_line "generated by $PROJECT" ~/.vimrc
remove_line "generated by $PROJECT" ~/.screenrc
if $CONFIG_DESKTOP; then
	remove_line "generated by $PROJECT" ~/.Xdefaults
fi

restore_backup ~/.gitconfig
restore_backup ~/.colordiffrc
if [ $UID -eq 0 ]; then
	restore_backup /etc/rsyslog.conf
fi

test -d "$CONFIG_ETC" && rm -r "$CONFIG_ETC"
test -d "$CONFIG_BIN" && rm -r "$CONFIG_BIN"
test -d "$CONFIG_SBIN" && rm -r "$CONFIG_SBIN"
test -d "$CONFIG_LIB" && rm -r "$CONFIG_LIB"
test -d "$CONFIG_SHARE" && rm -r "$CONFIG_SHARE"
test -d "$CONFIG_VROOT" && rmdir "$CONFIG_VROOT"
