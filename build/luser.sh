#!/bin/bash

set -xe

[ $# -eq 2 ] || exit 1
FUNCTION="$1"
CONFIG_FILE="$2"

source "$(dirname $BASH_SOURCE)/common.sh" "$CONFIG_FILE"

vim_exec()
{
	vim --cmd "$*" --cmd q
}

for_each_desktop_file()
{
	local DESKTOP_DIRNAME DESKTOP_FILENAME
	local INSTALLED_DESKTOP_ROOT="$CONFIG_ETC/desktop"
	if [ ! -d "$INSTALLED_DESKTOP_ROOT" ]; then
		return 0
	fi
	pushd "$INSTALLED_DESKTOP_ROOT" || return 2
	for DESKTOP_DIRNAME in *; do
		find $DESKTOP_DIRNAME -type f | while read DESKTOP_PATH; do
			local SRC="$INSTALLED_DESKTOP_ROOT/$DESKTOP_PATH"
			local DST="$HOME/.$DESKTOP_PATH"
			"$@" "$SRC" "$DST" || return 1
		done
	done
	popd
}

install_desktop_file()
{
	local SRC="$1"
	local DST="$2"
	safe_replace "$DST" \
		ln -sf $SRC @@@
}

uninstall_desktop_file()
{
	local SRC="$1"
	local DST="$2"
	restore_backup "$DST"
}

install_startup_file()
{
	local ENABLED=$1
	local BASE="${2}.desktop"
	local INSTALLED_DIR="$CONFIG_ETC/autostart"
	local INSTALLED_CONF="$INSTALLED_DIR/$BASE"
	local LOCAL_CONF="$HOME/.config/autostart/$BASE"
	local XDG_GLOBAL_CONF="/etc/xdg/autostart/$BASE"
	local APP_GLOBAL_CONF="/usr/share/applications/$BASE"

	if [ -f "$LOCAL_CONF" ];then
		mkbackup "$LOCAL_CONF" || return 1
		ensure_dir "$INSTALLED_CONF" || return 1
		mv "$LOCAL_CONF" "$INSTALLED_CONF" || return 1
	elif [ -f "$XDG_GLOBAL_CONF" ]; then
		ensure_dir "$INSTALLED_CONF" || return 1
		cp "$XDG_GLOBAL_CONF" "$INSTALLED_CONF" || return 1
	elif [ -f "$APP_GLOBAL_CONF" ]; then
		ensure_dir "$INSTALLED_CONF" || return 1
		cp "$APP_GLOBAL_CONF" "$INSTALLED_CONF" || return 1
	else
		return 0
	fi

	# for some reason, adding "X-MATE-Autostart-enabled=false" leaves the
	# thing enabled. to work around it, we remove any enabled line and only
	# add one back if it's really enabled.
	sed -i '/Autostart-enabled/d' "$INSTALLED_CONF" || return 1
	if ! $ENABLED; then
		local LINE="X-MATE-Autostart-enabled=${ENABLED}"
		add_projline "$INSTALLED_CONF" "$LINE" '#' || return 1
	fi
	ensure_dir "$LOCAL_CONF" || return 1
	ln -s "$INSTALLED_CONF" "$LOCAL_CONF" || return 1
	return 0
}

uninstall_startup_file()
{
	local BASE="${1}.desktop"
	local INSTALLED_DIR="$CONFIG_ETC/autostart"
	local INSTALLED_CONF="$INSTALLED_DIR/$BASE"
	local LOCAL_CONF="$HOME/.config/autostart/$BASE"
	if [ -L "$LOCAL_CONF" ]; then
		local DST=$(readlink "$LOCAL_CONF")
		if [ "$DST" = "$INSTALLED_CONF" ]; then
			unlink "$LOCAL_CONF" || return 1
		fi
	fi
	restore_backup "$LOCAL_CONF" || return 1
	rm -f "$INSTALLED_CONF" || return 1
	return 0
}

install()
{
	safe_replace $HOME/.gitconfig \
		ln -sf "$CONFIG_ETC/gitconfig" @@@
	safe_replace $HOME/.colordiffrc \
		ln -sf "$CONFIG_ETC/colordiffrc" @@@
	safe_replace $HOME/.config/htop/htoprc \
		ln -sf "$CONFIG_ETC/htoprc" @@@

	safe_edit $HOME/.screenrc \
		mksource 'source' "$CONFIG_ETC/screenrc" @@@ '#'

	safe_edit $HOME/.vimrc \
			mksource 'source' "$CONFIG_ETC/vimrc" @@@ '"'
	if [ -n "$(ls -A "$CONFIG_LIB/vim/doc")" ]; then
		vim_exec helptags "$CONFIG_LIB/vim/doc" # generate doc tags
	fi

	safe_edit $HOME/.bashrc \
			mksource 'source' "$CONFIG_ETC/bashrc" @@@ '#'
	if [ ! -f $HOME/.bash_profile ] && [ ! -f $HOME/.profile ]; then
		safe_edit $HOME/.bash_profile \
			mksource 'source' '$HOME/.bashrc' @@@
	fi

	if $CONFIG_MINT; then
		DEFAULT_USER_DIRS="$(grep '=' /etc/xdg/user-dirs.defaults \
			| cut -d= -f2 -s)"
		pushd $HOME
		uninstall_optional_dir $DEFAULT_USER_DIRS || true
		install_optional_dir "$CONFIG_DESKTOP_DIR" "$CONFIG_HOME_TMP_DIR"
		popd

		safe_replace "$HOME/.config/user-dirs.dirs" \
			ln -sf "$CONFIG_ETC/user-dirs.dirs" @@@

		for_each "$CONFIG_AUTOSTART_DISABLE" ':' \
			install_startup_file false
		for_each "$CONFIG_AUTOSTART_ENABLE" ':' \
			install_startup_file true
	fi

	if $CONFIG_DESKTOP; then
		test -d "$CONFIG_SHARE" || exit 1

		safe_edit $HOME/.Xdefaults \
			mksource '#include' "\"$CONFIG_ETC/xdefaults\"" @@@ '/*' '*/'

		for_each_desktop_file \
			install_desktop_file
	fi

	xz -d "$CONFIG_SHARE/hebrew.txt.xz"

	install_optional_dir "$CONFIG_WORKSPACE"
}

uninstall()
{
	rm -f "$CONFIG_SHARE/hebrew.txt"

	restore_backup "$HOME/.config/user-dirs.dirs"
	pushd $HOME
	uninstall_optional_dir \
		"$CONFIG_DESKTOP_DIR" \
		"$CONFIG_HOME_TMP_DIR"
	popd

	uninstall_optional_dir "$CONFIG_WORKSPACE"

	for_each_desktop_file \
		uninstall_desktop_file

	for_each "$CONFIG_AUTOSTART_DISABLE" ':' \
		uninstall_startup_file
	for_each "$CONFIG_AUTOSTART_ENABLE" ':' \
		uninstall_startup_file

	rm -f "$CONFIG_LIB/vim/doc/tags"

	rmsource $HOME/.Xdefaults
	rmsource $HOME/.bash_profile
	rmsource $HOME/.bashrc
	rmsource $HOME/.vimrc
	rmsource $HOME/.screenrc
	restore_backup $HOME/.config/htop/htoprc
	restore_backup $HOME/.colordiffrc
	restore_backup $HOME/.gitconfig
}

"$FUNCTION"
