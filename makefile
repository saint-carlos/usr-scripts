BUILD=build
CONFIG_FILE=config.sh

all: build

build: ${CONFIG_FILE} src tgt
	sh -e ${CONFIG_FILE}
	./${BUILD}/replace_params.sh ${CONFIG_FILE} src tgt

tgt:
	mkdir tgt

install: build tgt ${CONFIG_FILE}
	./${BUILD}/install.sh ${CONFIG_FILE} tgt true

install_nouser: build tgt ${CONFIG_FILE}
	./${BUILD}/install.sh ${CONFIG_FILE} tgt false


clean:
	rm -rf tgt

.PHONY: clean build all install
