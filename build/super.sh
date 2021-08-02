#!/bin/bash -p

set -o xtrace
set -o errexit nounset
set -o privileged

[ $# -eq 2 ] || exit 1
FUNCTION="$1"
CONFIG_FILE="$2"

source "$(dirname $BASH_SOURCE)/common.sh" "$CONFIG_FILE"

ADM_GROUP=adm
SUDO_GROUP=sudo
GROUPDB="$CONFIG_ETC/gpasswd"

mkgroupdb()
{
	if [ -d "$GROUPDB" ]; then
		return 0
	fi
	mkdir -p "$GROUPDB" || return 1
	chown -R "$CONFIG_USER_NAME:$PRIMARY_GROUP" "$GROUPDB" || return 1
	return 0
}

add_user_to_group()
{
	local U=$1
	local G=$2

	local PRIMARY_GROUP=$(id --name --group $CONFIG_USER_NAME) || return 1

	echo "adding user '$U' to the '$G' group..."
	if ! getent group $G > /dev/null; then
		echo "'$G' group doesn't exist, skipping"
		return 0
	fi
	if getent group $G \
			| cut -d: -f4 \
			| tr ',' '\n' \
			| grep -q --line-regexp "$U"; then
		echo "user '$U' is in '$G' group; not touching it"
		return 0
	fi
	mkgroupdb || return 1
	COOKIE_FILE="$GROUPDB/${U}:${G}"
	touch "$COOKIE_FILE"
	echo "cookie" > "$COOKIE_FILE" \
			|| echo 2>&1 "warning: cannot set cookie '$COOKIE_FILE'"
	chown -R "$CONFIG_USER_NAME:$PRIMARY_GROUP" "$COOKIE_FILE" || return 1
	gpasswd --add $U $G || return 1
	return 0
}

remove_user_from_group()
{
	local U=$1
	local G=$2
	COOKIE_FILE="$GROUPDB/${U}:${G}"
	if ! [ -e "$COOKIE_FILE" ]; then
		return 0
	fi
	echo "removing user $U from the '$G' group"
	if ! [ -f "$COOKIE_FILE" ] ||
			[ "$(cat "$COOKIE_FILE")" != "cookie" ]; then
		echo 2>&1 "warning: cookie'$COOKIE_FILE' is fishy, not touching"
		return 0
	fi
	gpasswd --delete $U $G || return 1
	rm "$COOKIE_FILE" || return 1
	return 0
}

do_install()
{
	[ $UID -eq 0 ] || return 1

	# we can't link it because rsyslog is stupid
	safe_replace /etc/rsyslog.conf \
		cp "$CONFIG_ETC/rsyslog.conf" @@@

	safe_install /etc/sudoers.d/98-${PROJECT} \
		install -m 0440 "$CONFIG_ETC/sudoers" @@@

	safe_install /etc/sysctl.d/98-${PROJECT}.conf \
		ln -sf "$CONFIG_ETC/sysctl.conf" @@@
	sysctl --system

	safe_replace /etc/default/grub \
		ln -sf "$CONFIG_ETC/grub" @@@
	update-grub
}

do_uninstall()
{
	[ $UID -eq 0 ] || return 1

	restore_backup /etc/default/grub
	update-grub

	restore_backup /etc/rsyslog.conf
	rm -f /etc/sudoers.d/98-${PROJECT}

	rm -f /etc/sysctl.d/98-${PROJECT}.conf
	sysctl --system
}

do_mksudo()
{
	[ $UID -eq 0 ] || return 1

	echo "sudo timeout is $CONFIG_SUDO_TIMEOUT_MINS > 0:"
	add_user_to_group $CONFIG_USER_NAME $ADM_GROUP
	add_user_to_group $CONFIG_USER_NAME $SUDO_GROUP
	for_each $CONFIG_NONDEFAULT_GROUPS ':' \
		add_user_to_group $CONFIG_USER_NAME
}

do_rmsudo()
{
	[ $UID -eq 0 ] || return 1

	for_each $CONFIG_NONDEFAULT_GROUPS ':' \
		remove_user_from_group $CONFIG_USER_NAME
	remove_user_from_group $CONFIG_USER_NAME $SUDO_GROUP
	remove_user_from_group $CONFIG_USER_NAME $ADM_GROUP
}

"do_${FUNCTION}"
