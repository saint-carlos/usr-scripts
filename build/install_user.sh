#!/bin/bash -xe

backup()
{
	FILE="$1"
	BACKUP_FILE=$(make_backup_file "$FILE")
	if [ -f "$BACKUP_FILE" ]; then
		echo "cannot backup $FILE" >&2
		exit 2
	fi
	if [ -f "$FILE" ]; then
		cp "$FILE" "$BACKUP_FILE"
	fi
}

rmbackup()
{
	FILE="$1"
	BACKUP_FILE="${FILE}.bak.${PROJECT}"
	rm -f "$BACKUP_FILE"
}

[ $# -eq 1 ] || exit 1

PARAMS_FILE="$1"
source "$PARAMS_FILE"
source "$(dirname $BASH_SOURCE)/common.sh"
test -d "$CONFIG_ETC" || exit 1

backup ~/.bashrc
echo "source $CONFIG_ETC/bashrc # generated by $PROJECT" >> ~/.bashrc
rmbackup ~/.bashrc

backup ~/.vimrc
echo "source $CONFIG_ETC/vimrc \" generated by $PROJECT" >> ~/.vimrc
rmbackup ~/.vimrc

backup ~/.gitconfig
ln -sf "$CONFIG_ETC/gitconfig" ~/.gitconfig

if [ -n "$(ls -A $CONFIG_LIB/vim/doc)" ]; then
	vim_exec helptags "$CONFIG_LIB/vim/doc" # generate doc tags
fi

backup ~/.screenrc
echo "source $CONFIG_ETC/screenrc # generated by $PROJECT" >> ~/.screenrc
rmbackup ~/.screenrc

backup ~/.colordiffrc
ln -sf "$CONFIG_ETC/colordiffrc" ~/.colordiffrc

if $CONFIG_DESKTOP; then
	test -d "$CONFIG_SHARE" || exit 1

	backup ~/.Xdefaults
	echo "#include \"$CONFIG_ETC/xdefaults\" /* generated by $PROJECT */" >> ~/.Xdefaults
	rmbackup ~/.Xdefaults
fi

if [ $UID -eq 0 ]; then
	backup /etc/rsyslog.conf
	ln -sf  "$CONFIG_ETC/rsyslog.conf" /etc/rsyslog.conf
fi
