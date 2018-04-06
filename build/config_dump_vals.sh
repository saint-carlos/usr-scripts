#!/bin/bash

bash --noprofile --norc -c \
	"source $1 && declare" \
	| grep "^CONFIG_"
