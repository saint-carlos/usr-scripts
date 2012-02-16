BUILD=build
CONFIG_FILE=config.sh
export PROJECT=usr_scripts

FILES=$(patsubst src/%, %, $(wildcard src/*/*))

SED_COMMANDS=$(shell ./${BUILD}/make_sed_commands.sh ${CONFIG_FILE})

all: build

build: $(addprefix tgt/,${FILES})

basedir = $(shell basename $(dir $1))
tmpdir = tmp/$(call basedir,$1)

tgt/%: src/% ./${BUILD}/make_sed_commands.sh tmp/.valid_config
	mkdir -p $(dir $@) $(call tmpdir,$@)
	cp -f $< $(call tmpdir,$@)
	./${BUILD}/binary $@ || sed -i "${SED_COMMANDS}" $(call tmpdir,$@)/$(notdir $@)
	mv $(call tmpdir,$@)/$(notdir $@) $@

tmp/.valid_config: ${CONFIG_FILE}
	sh -e $<
	mkdir -p $(dir $@)
	touch $@

install: build tgt ${CONFIG_FILE}
	./${BUILD}/install.sh ${CONFIG_FILE} tgt

install_user: build tgt ${CONFIG_FILE}
	./${BUILD}/install_user.sh ${CONFIG_FILE}

install_all: install install_user

uninstall: ${CONFIG_FILE}
	./${BUILD}/uninstall.sh ${CONFIG_FILE}

clean:
	rm -rf tgt tmp

help:
	@echo TODO

test:
	@echo "files:"
	@echo "${FILES}"
	@echo
	@echo "config file:"
	@cat ${CONFIG_FILE}
	@echo
	@echo "sed commands:"
	@echo "${SED_COMMANDS}"
	@echo
	@echo basedir: "$(call basedir,tgt/dir/test)"
	@echo tmpdir: "$(call tmpdir,tgt/dir/test)"

.PHONY: clean build all install install_user install_all uninstall tgt help test
