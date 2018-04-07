#!/bin/bash

set -xe

[ $# -eq 2 ] || exit 1
FUNCTION="$1"
CONFIG_FILE="$2"

source "$(dirname $BASH_SOURCE)/common.sh" "$CONFIG_FILE"

ADM_GROUP=adm
SUDO_GROUP=sudo
GROUPDB="$CONFIG_ETC/gpasswd"

link_secure()
{
	local SRC="$1"
	local DST="$2"
	# for security reasons, we copy the file rather than link it
	mkbackup "$DST" || return 1
	local BACKUP_FILE="$(make_backup_filename "$DST")"
	cp "$SRC" "$DST" || return 1
	chmod --reference="$BACKUP_FILE" "$DST" || return 1
	return 0
}

unlink_secure()
{
	restore_backup "$1"
}

pam_setup()
{
	cp "$CONFIG_ETC/pam.conf" "/etc/pam.d/$PROJECT" || return 1
	return 0
}

pam_teardown()
{
	rm -f "/etc/pam.d/$PROJECT" || return 1
	return 0
}

pam_edit()
{
	local DST_FILE="$1"
	local PAM_CMT='#'
	mkbackup "$DST_FILE"
	comment_out '\s*session.*pam_motd.so.*' "$DST_FILE" "$PAM_CMT" || return 1
	comment_out '\s*session.*pam_lastlog.*' "$DST_FILE" "$PAM_CMT" || return 1
	mksource "@include" $PROJECT "$DST_FILE" "$PAM_CMT" || return 1
	return 0
}

pam_unedit()
{
	local DST_FILE="$1"
	restore_backup "$DST_FILE"
}

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

install()
{
	[ $UID -eq 0 ] || return 1

	# we can't link it because rsyslog is stupid
	safe_replace /etc/rsyslog.conf \
		cp "$CONFIG_ETC/rsyslog.conf" @@@

	pam_setup

	pam_edit /etc/pam.d/login

	link_secure "$CONFIG_ETC/sshd_config" /etc/ssh/sshd_config
	mkdir -p /run/sshd
	pam_edit /etc/pam.d/sshd

	link_secure "$CONFIG_ETC/sudoers" /etc/sudoers
	link_secure "$CONFIG_ETC/login.defs" /etc/login.defs
	link_secure "$CONFIG_ETC/sysctl.conf" /etc/sysctl.conf
	if [ -f /etc/selinux/config ]; then
		link_secure "$CONFIG_ETC/selinux.conf" /etc/selinux/config
	fi
}

uninstall()
{
	[ $UID -eq 0 ] || return 1

	restore_backup /etc/rsyslog.conf
	unlink_secure /etc/selinux/config
	unlink_secure /etc/sysctl.conf
	unlink_secure /etc/login.defs
	unlink_secure /etc/sudoers
	unlink_secure /etc/ssh/sshd_config
	pam_unedit /etc/pam.d/login
	pam_unedit /etc/pam.d/sshd
	pam_teardown
	# rmdir /run/sshd # that would be more annoying than useful
}

mksudo()
{
	[ $UID -eq 0 ] || return 1

	if [ $CONFIG_SUDO_TIMEOUT_MINS -gt 0 ]; then
		echo "sudo timeout is $CONFIG_SUDO_TIMEOUT_MINS > 0:"
		add_user_to_group $CONFIG_USER_NAME $ADM_GROUP
		add_user_to_group $CONFIG_USER_NAME $SUDO_GROUP
	fi
	for_each $CONFIG_NONDEFAULT_GROUPS ':' \
		add_user_to_group $CONFIG_USER_NAME
}

rmsudo()
{
	[ $UID -eq 0 ] || return 1

	for_each $CONFIG_NONDEFAULT_GROUPS ':' \
		remove_user_from_group $CONFIG_USER_NAME
	remove_user_from_group $CONFIG_USER_NAME $SUDO_GROUP
	remove_user_from_group $CONFIG_USER_NAME $ADM_GROUP
}

"$FUNCTION"
