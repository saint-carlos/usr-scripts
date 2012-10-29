#!/bin/sh
ETC_PLACEHOLDER=~/vroot/etc
BIN_PLACEHOLDER=~/vroot/bin
SBIN_PLACEHOLDER=~/vroot/sbin
USERNAME_PLACEHOLDER="${USER}"
HOSTNAME_PLACEHOLDER="$(hostname -s)"
DNS_DOMAIN_PLACEHOLDER="$(hostname -d)"
USER_FULL_NAME_PLACEHOLDER="$(getent passwd "${USERNAME_PLACEHOLDER}" | cut -d: -f5 | cut -d, -f1)"
USERMAIL_PLACEHOLDER="${USERNAME_PLACEHOLDER}@${DNS_DOMAIN_PLACEHOLDER}"
USER_PROMPT_COLOR_PLACEHOLDER=GREEN # see colorsrc
ROOT_PROMPT_COLOR_PLACEHOLDER=YELLOW # see colorsrc
