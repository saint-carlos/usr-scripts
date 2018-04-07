#!/bin/bash

source "$1"

CONFIG_ETC=$CONFIG_VROOT/etc
CONFIG_BIN=$CONFIG_VROOT/bin
CONFIG_SBIN=$CONFIG_VROOT/sbin
CONFIG_LIB=$CONFIG_VROOT/lib
CONFIG_SHARE=$CONFIG_VROOT/share

if $CONFIG_DESKTOP && grep LinuxMint /etc/lsb-release &>/dev/null; then
	CONFIG_MINT=true
else
	CONFIG_MINT=false
fi

CONFIG_SYSLOG_FILE=/var/log/syslog
if ! [ -f "$CONFIG_SYSLOG_FILE" ]; then
	CONFIG_SYSLOG_FILE=/var/log/messages
fi
