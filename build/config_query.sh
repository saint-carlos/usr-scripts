#!/bin/bash

source "$(dirname $BASH_SOURCE)/config_allvars.sh" "$1"
C="${!2}"
[ -z "$C" ] && exit 1
echo "$C"
