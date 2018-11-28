#!/bin/bash -x

[ $# -eq 2 ] || exit 1
findmnt "$1" || exit 1
findmnt "$2" || exit 1
rsync -aHSx -P --numeric-ids "$1" "$2"
