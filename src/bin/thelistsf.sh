#!/bin/bash

PROGRAM=$(basename $0)

parse_page()
{
	cat "$1" \
		| grep '<LI>' | grep -v '<UL>$' \
		| sed 's@<LI>.*<B><A HREF=".*">.*</A></B>@@' \
		| sed 's@<A HREF="[^>"]*">\([^<]*\)</A>@==\1~~\n@g' \
		| grep -o '==[^~]*~~' \
		| sed 's@==\([^~]*\)~~@\1@'
}

main()
{
	local WEEKS=${1:-1}
	local HTML="/tmp/${PROGRAM}.html"
	local LIST="/tmp/${PROGRAM}.lst"
	: > "$LIST"
	for ((i=0; i < WEEKS; i++)); do
		wget --output-document "$HTML" "http://www.foopee.com/punk/the-list/by-date.${i}.html"
		parse_page "$HTML" >> "$LIST"
	done
	sort -u "$LIST"
}

main "$@"
