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

	if $CONFIG_DESKTOP; then
		test -d "$CONFIG_SHARE" || exit 1

		safe_edit $HOME/.Xdefaults \
			mksource '#include' "\"$CONFIG_ETC/xdefaults\"" @@@ '/*' '*/'
	fi

	xz -d "$CONFIG_SHARE/hebrew.txt.xz"

	install_optional_dir "$CONFIG_WORKSPACE"
}

uninstall()
{
	rm -f "$CONFIG_SHARE/hebrew.txt"

	uninstall_optional_dir "$CONFIG_WORKSPACE"

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
