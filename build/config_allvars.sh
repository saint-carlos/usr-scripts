#!/bin/bash

source "$1"

allvars_make_dconf_list()
{
	local LIST=$1
	local DELIM=$2
	local RES="["
	local SEP=""
	local X
	for X in $(tr "$DELIM" '\n' <<< "$LIST"); do
		RES+="${SEP}'${X}'"
		SEP=", "
	done
	RES+="]"
	echo "$RES"
}

allvars_list_has()
{
	local LIST=$1
	local DELIM=$2
	local SUBJ=$3
	tr "$DELIM" '\n' <<< "$LIST" | grep -q --fixed-string "$SUBJ"
}

CONFIG_ETC=$CONFIG_VROOT/etc
CONFIG_BIN=$CONFIG_VROOT/bin
CONFIG_SBIN=$CONFIG_VROOT/sbin
CONFIG_LIB=$CONFIG_VROOT/lib
CONFIG_SHARE=$CONFIG_VROOT/share

CONFIG_RTL_DICTIONARIES=""
CONFIG_LTR_DICTIONARIES=""
if $CONFIG_DESKTOP; then
	CONFIG_LTR_DICTIONARIES+="/usr/share/dict/words"
	if allvars_list_has $CONFIG_LANGUAGES ':' "il"; then
		CONFIG_RTL_DICTIONARIES+=" $CONFIG_SHARE/hebrew.txt"
	fi
fi

if $CONFIG_DESKTOP && grep LinuxMint /etc/lsb-release &>/dev/null; then
	CONFIG_MINT=true
	DCONF_LOCATION_EXEC="$(dirname $BASH_SOURCE)/dconf_locations.py"
	CONFIG_DCONF_LOCATIONS="$("$DCONF_LOCATION_EXEC" "$CONFIG_CITIES")"
	[ $? -eq 0 ] || exit 1
	CONFIG_DCONF_LOCATIONS="$(sed 's/"/\\"/g' <<< "$CONFIG_DCONF_LOCATIONS")"

	NUM_MONITORS_EXEC="$(dirname $BASH_SOURCE)/count_monitors.sh"
	CONFIG_NUM_MONITORS=$("$NUM_MONITORS_EXEC")
	if [ $CONFIG_NUM_MONITORS -ge 2 ]; then
		CONFIG_DCONF_PANEL_TOPLEVEL_OBJS="['bottom', 'toplevel-0']"
	else
		CONFIG_DCONF_PANEL_TOPLEVEL_OBJS="['bottom']"
	fi
else
	CONFIG_MINT=false
	CONFIG_PANEL_DCONF_TOPLEVEL_OBJS="[]"
	CONFIG_DCONF_LOCATIONS="[]"
fi

CONFIG_SYSLOG_FILE=/var/log/syslog
if ! [ -f "$CONFIG_SYSLOG_FILE" ]; then
	CONFIG_SYSLOG_FILE=/var/log/messages
fi

CONFIG_DCONF_KEYBOARD_LAYOUTS="$(allvars_make_dconf_list "$CONFIG_LANGUAGES" ':')"

unset allvars_make_dconf_list allvars_list_has
