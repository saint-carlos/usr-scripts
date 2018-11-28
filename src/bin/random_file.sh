#!/bin/bash -e

f()
{
	find "$@" '(' -type f ')' -o '(' -type l ')'
}

d()
{
	find "$@" -type d
}

F=$1
N=$2
shift 2

# COUNT=$($F "$@" | wc -l)
# C=$((RANDOM % COUNT + 1))
# SCRIPT="${C}p"
# for ((i=1; i < N; i++)); do
# 	R=$RANDOM
# 	C=$((RANDOM % COUNT + 1))
# 	SCRIPT="${SCRIPT}; ${C}p"
# done
$F "$@" | sort -R | head -n $N
