BUILD=build
CONFIG_FILE=config.sh
export PROJECT=usr_scripts

all: build

build: ${CONFIG_FILE} src tgt
	sh -e ${CONFIG_FILE}
	./${BUILD}/replace_params.sh ${CONFIG_FILE} src tgt

tgt:
	mkdir tgt

install: build tgt ${CONFIG_FILE}
	./${BUILD}/install.sh ${CONFIG_FILE} tgt

install_user: build tgt ${CONFIG_FILE}
	./${BUILD}/install_user.sh ${CONFIG_FILE}

install_all: install install_user

uninstall: ${CONFIG_FILE}
	./${BUILD}/uninstall.sh ${CONFIG_FILE}

clean:
	rm -rf tgt

.PHONY: clean build all install install_user install_all uninstall
