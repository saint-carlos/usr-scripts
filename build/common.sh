#!/bin/bash

make_temp_file()
{
	echo "$1.tmp.${PROJECT}"
}

make_backup_file()
{
	echo "$1.bak.${PROJECT}"
}

