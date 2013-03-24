#!/bin/bash

ETC_PLACEHOLDER=$VROOT_PLACEHOLDER/etc
BIN_PLACEHOLDER=$VROOT_PLACEHOLDER/bin
SBIN_PLACEHOLDER=$VROOT_PLACEHOLDER/sbin
LIB_PLACEHOLDER=$VROOT_PLACEHOLDER/lib

make_temp_file()
{
	echo "${1}.tmp.${PROJECT}"
}

make_backup_file()
{
	echo "${1}.bak.${PROJECT}"
}

vim_exec()
{
	vim --cmd "$*" --cmd q
}
