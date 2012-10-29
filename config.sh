#!/bin/sh
ETC_PLACEHOLDER=~/etc
BIN_PLACEHOLDER=~/bin
SBIN_PLACEHOLDER=~/sbin
USERNAME_PLACEHOLDER="${USER}"
HOSTNAME_PLACEHOLDER="${HOSTNAME}"
USER_FULL_NAME_PLACEHOLDER="`grep ${USERNAME_PLACEHOLDER} /etc/passwd | cut -d: -f5 | cut -d, -f1`"
USERMAIL_PLACEHOLDER="${USERNAME_PLACEHOLDER}@${HOSTNAME_PLACEHOLDER}"
