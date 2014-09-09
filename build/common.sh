#!/bin/bash

CONFIG_ETC=$CONFIG_VROOT/etc
CONFIG_BIN=$CONFIG_VROOT/bin
CONFIG_SBIN=$CONFIG_VROOT/sbin
CONFIG_LIB=$CONFIG_VROOT/lib

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
