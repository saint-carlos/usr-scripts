#!/bin/bash

source "$@"
C="${!2}"
[ -z "$C" ] && exit 1
echo "$C"
