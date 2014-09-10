#!/bin/bash

source $1
C=${!2}
[ -z "$C" ] && exit 1
echo $C
