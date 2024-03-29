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

make_fimmutable()
{
	local DST="$1"
	ensure_dir "$DST" || return 1
	rm -f "$DST" || return 1
	mkdir -p "$DST" || return 1
	touch "$DST/0" || return 1
	echo "disabled" > "$DST/0" || return 1
	chmod 0000 "$DST"
	return 0
}

make_dimmutable()
{
	local DST="$1"
	ensure_dir "$DST" || return 1
	rm -r "$DST" || ! test -d "$DST" || return 1
	touch "$DST" || return 1
	echo "disabled" > "$DST" || return 1
	return 0
}

make_fmutable()
{
	local DST="$1"
	test -d "$DST" || return 0
	chmod 0777 "$DST"
	rm "$DST/0" || return 1
	rmdir "$DST" || return 1
	touch "$DST" || return 1
	return 0
}

make_dmutable()
{
	local DST="$1"
	test -f "$DST" || return 0
	rm -f "$DST" || return 1
	mkdir "$DST" || return 1
	return 0
}

do_install()
{
	safe_replace $HOME/.gitconfig \
		ln -sf "$CONFIG_ETC/gitconfig" @@@
	safe_replace $HOME/.colordiffrc \
		ln -sf "$CONFIG_ETC/colordiffrc" @@@
	safe_replace $HOME/.config/htop/htoprc \
		ln -sf "$CONFIG_ETC/htoprc" @@@
	safe_replace $HOME/.gdbinit \
		ln -sf "$CONFIG_ETC/gdbinit" @@@
	safe_replace $HOME/.inputrc \
		ln -sf "$CONFIG_ETC/inputrc" @@@


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
		xrdb -load $HOME/.Xdefaults

		for_each_desktop_file \
			install_desktop_file
	fi

	if $CONFIG_DESKTOP && $CONFIG_SECURE; then
		pushd $HOME
		for_each "$CONFIG_DISABLE_CACHE_FILES" ':' \
			make_fimmutable
		for_each "$CONFIG_DISABLE_CACHE_DIRS" ':' \
			make_dimmutable
		popd
	fi

	if grep "hebrew" <<< "$CONFIG_RTL_DICTIONARIES"; then
		xz -d "$CONFIG_SHARE/hebrew.txt.xz"
	fi

	install_optional_dir "$CONFIG_WORKSPACE"
}

do_uninstall()
{
	rm -f "$CONFIG_SHARE/hebrew.txt"

	restore_backup "$HOME/.config/user-dirs.dirs"
	pushd $HOME
	uninstall_optional_dir \
		"$CONFIG_DESKTOP_DIR" \
		"$CONFIG_HOME_TMP_DIR"
	popd

	uninstall_optional_dir "$CONFIG_WORKSPACE"

	if $CONFIG_DESKTOP && $CONFIG_SECURE; then
		pushd $HOME
		for_each "$CONFIG_DISABLE_CACHE_FILES" ':' \
			make_fmutable
		for_each "$CONFIG_DISABLE_CACHE_DIRS" ':' \
			make_dmutable
		popd
	fi

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
	restore_backup $HOME/.inputrc
	restore_backup $HOME/.gdbinit
	restore_backup $HOME/.config/htop/htoprc
	restore_backup $HOME/.colordiffrc
	restore_backup $HOME/.gitconfig
}

dconf_sync()
{
	sleep 3
	dconf "$@"
}

do_install_desktoprefresh()
{
	CONFIG_DCONF="$CONFIG_ETC/dconf"
	if $CONFIG_MINT; then
		BACKUP_FILE=$(make_backup_filename $HOME/.config/dconf/user)
		dconf_sync dump / > "$BACKUP_FILE"
		cp $CONFIG_DCONF/dconf_user.ini $CONFIG_DCONF/dconf_user.stage1.ini
		if [ $CONFIG_NUM_MONITORS -ge 2 ]; then
			cat $CONFIG_DCONF/dconf_user.monitor2.ini \
				>> $CONFIG_DCONF/dconf_user.stage1.ini
		fi
		if $CONFIG_HAS_TOUCHPAD; then
			cat $CONFIG_DCONF/dconf_user.touchpad.ini \
				>> $CONFIG_DCONF/dconf_user.stage1.ini
			DESKTOPREFRESH_KEYBOARD=touchpad
		else
			DESKTOPREFRESH_KEYBOARD=desktop
		fi
		cat $CONFIG_DCONF/dconf_user.stage1.ini \
			| sed "/CONFIG_DCONF_MEDIA/r ${CONFIG_DCONF}/dconf_user.${DESKTOPREFRESH_KEYBOARD}.media.ini" \
			| sed "/CONFIG_DCONF_WINDOWS/r ${CONFIG_DCONF}/dconf_user.${DESKTOPREFRESH_KEYBOARD}.windows.ini" \
			| sed '/CONFIG_DCONF_MEDIA/d; /CONFIG_DCONF_WINDOWS/d' \
			> "$CONFIG_DCONF/dconf_user.final.ini"

		# we don't reset the rest of the config, we
		# only touch what we care about
		dconf_sync load / < "$CONFIG_DCONF/dconf_user.final.ini"
	fi
}

do_uninstall_desktoprefresh()
{
	if $CONFIG_MINT; then
		BACKUP_FILE=$(make_backup_filename $HOME/.config/dconf/user)
		if [ -f "$BACKUP_FILE" ]; then
			dconf_sync reset -f / || echo "dconf reset failed, loading anyway"
			dconf_sync load / < "$BACKUP_FILE" || return 1
		fi
		rm -f "$CONFIG_ETC/dconf_user.final.ini"

	fi
}

extract()
{
	local DIR="$1"
	local ARCHIVE="$2"
	pushd "$DIR"
	xz --decompress "$ARCHIVE" || return 1
	ARCHIVE="${ARCHIVE%%.xz}"
	tar xf "$ARCHIVE" || return 1
	popd
}

"do_${FUNCTION}"
