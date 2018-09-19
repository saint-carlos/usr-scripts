#!/bin/bash

bash --noprofile --norc -c \
	"source $* && declare +aAF" \
	| grep "^CONFIG_"
