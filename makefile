BUILD=build
CONFIG_FILE=config.sh
DEFAULT_CONFIG_FILE=${BUILD}/default_config.sh
VALID_CONFIG=tmp/.valid_config
export PROJECT=usr_scripts

FILES=$(patsubst src/%, %, $(wildcard	\
	src/bin/*			\
	src/sbin/*			\
	src/etc/*			\
	src/lib/vim/*/*			\
))

SED_COMMANDS=$(shell ./${BUILD}/make_sed_commands.sh ${CONFIG_FILE})

all: build # equivalent to build

build: $(addprefix tgt/,${FILES}) # create configured scripts/config files in tgt/, ready to be installed

${CONFIG_FILE}: ${DEFAULT_CONFIG_FILE}
	test -f $@ || cp $< $@

config: ${VALID_CONFIG} # create a config file from the default settings

basedir = $(shell basename $(dir $1))
tmpdir = tmp/$(call basedir,$1)

tgt/%: src/% ./${BUILD}/make_sed_commands.sh ${VALID_CONFIG}
	mkdir -p $(dir $@) $(call tmpdir,$@)
	cp -f $< $(call tmpdir,$@)
	./${BUILD}/binary $@ || sed -i "${SED_COMMANDS}" $(call tmpdir,$@)/$(notdir $@)
	mv $(call tmpdir,$@)/$(notdir $@) $@

${VALID_CONFIG}: ${CONFIG_FILE}
	sh -e $<
	mkdir -p $(dir $@)
	touch $@

install: build tgt ${CONFIG_FILE} # install configured scripts/config files from tgt/
	./${BUILD}/install.sh ${CONFIG_FILE} tgt ${FILES}

install_user: build tgt ${CONFIG_FILE} # update the user configuration to accommodate an installed scripts/config files
	./${BUILD}/install_user.sh ${CONFIG_FILE}

install_all: install install_user # install configured scripts/config files and update the user configuration to accommodate them

uninstall: ${CONFIG_FILE} # remove the scripts/config files from the user configuration and delete them
	./${BUILD}/uninstall.sh ${CONFIG_FILE}

update: uninstall install_all # update a user configuration from the repository

tags:: # create tags
	ctags -R --language-force=sh .

clean: # remove built targets
	rm -rf tgt tmp

mrproper: clean # remove everything generate by any build target from the project's directory
	rm -f config.sh tags

help: # this message
	@egrep '^[a-zA-Z0-9]*::?( |$$)' ${MAKEFILE_LIST} | sed 's/:[^#]*$$//; s/:.*# /\t - /'

test: # dump configuration
	@echo "files:"
	@echo "${FILES}"
	@echo
	@echo "config file:"
	@cat ${CONFIG_FILE}
	@echo
	@echo "sed commands:"
	@echo " ${SED_COMMANDS}" | tr ';' '\n'
	@echo
	@echo basedir: "$(call basedir,tgt/dir/test)"
	@echo tmpdir: "$(call tmpdir,tgt/dir/test)"

.PHONY: clean build all install install_user install_all uninstall tgt help test config mrproper
