#!/bin/bash -e

[ $# -eq 1 ] || exit 1

source "$@"

print_vars()
{
	if [ "${CONFIG_OS}" = "mac" ]; then
		declare +af
	else
		declare +aAF
	fi
}

if [ "${CONFIG_OS}" = "mac" ]; then
	WORD_START_REGEX='[[:<:]]'
	WORD_END_REGEX='[[:>:]]'
else
	WORD_START_REGEX='\<'
	WORD_END_REGEX='\>'
fi

for VAR in $(print_vars | grep '^CONFIG_[0-9A-Z_]*=' | cut -d= -f1 -s); do
	echo "s|${WORD_START_REGEX}${VAR}${WORD_END_REGEX}|${!VAR}|g;"
done
