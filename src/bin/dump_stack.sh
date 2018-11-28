#!/bin/bash
shopt -s extdebug

dump_stack()
{
	STACK_POINTER=0
	for ((i=1; i < ${#FUNCNAME[@]}; i++)); do
		printf "%s:%d %s" "${BASH_SOURCE[$i]}" "${BASH_LINENO[$((i-1))]}" "${FUNCNAME[$i]}("
		NEW_STACK_POINTER=$((STACK_POINTER + ${BASH_ARGC[$i]:-0}))
		SPACE=""
		for ((j=NEW_STACK_POINTER-1; j >= STACK_POINTER; j--)); do
			printf "${SPACE}%s" "${BASH_ARGV[$j]}"
			SPACE=", "
		done
		STACK_POINTER=$NEW_STACK_POINTER
		printf ")\n"
	done
}

