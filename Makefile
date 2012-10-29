BUILD=build
CONFIG_FILE=config.txt

all: build

build: ${CONFIG_FILE} src tgt
	./${BUILD}/replace_params.sh ${CONFIG_FILE} src tgt

${CONFIG_FILE}::
	sh -e $@

tgt:
	mkdir tgt

install:

clean:
	rm -rf tgt

.PHONY: verify clean build all
