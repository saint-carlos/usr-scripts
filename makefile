# at some point, your workplace WILL force you to work on a mac.
# the mac has OLD unix utils.
# make sure the build & install process can work with these old unit utils,
# so that they can automatically install modern unix utils.

TMP_CFG			:= tmp/cfg
THIS_MAKEFILE		:= $(firstword ${MAKEFILE_LIST})
BUILD 			:= ./build
USER_CONFIG_VARS	:= ${TMP_CFG}/config_vars.user.txt
DEFAULT_CONFIG_FILE	:= ${BUILD}/default_config.sh

export ALL_CONFIG_VARS	:= ${TMP_CFG}/config_vars.all.sh
export SED_SCRIPT	:= ${TMP_CFG}/replace_vars.sed
export CONFIG_FILE	:= config.sh

CONFIG_ARTIFACTS	:= ${CONFIG_FILE} ${ALL_CONFIG_VARS} ${SED_SCRIPT}

all: build # equivalent to build

build: ${CONFIG_ARTIFACTS} # create configured scripts/config files in tgt/, ready to be installed
	$(MAKE) -C build/ $@

config: ${BUILD}/config_dump_vals.sh ${CONFIG_ARTIFACTS} # upgrade or create a config file from the default settings
	@echo --------------------------------
	@echo config file written to '${CONFIG_FILE}'
	@echo please review the configuration:
	@echo --------------------------------
	@bash ${BUILD}/config_dump_vals.sh ${CONFIG_FILE}

install_luser: ${CONFIG_ARTIFACTS}
	$(MAKE) -C ${BUILD} $@

uninstall_luser: ${CONFIG_ARTIFACTS} # uninstall scripts and config of current user
	$(MAKE) -C ${BUILD} $@

upgrade_luser: # install/upgrade scripts and config of current user
	$(MAKE) uninstall_luser
	$(MAKE) install_luser

install_super: ${CONFIG_ARTIFACTS} ${INSTALLED_SUPER_FILES}
	$(MAKE) -C ${BUILD} $@

uninstall_super: ${CONFIG_ARTIFACTS} # uninstall administrative scripts and config
	$(MAKE) -C ${BUILD} $@

upgrade_super: # install/upgrade administrative scripts and config
	$(MAKE) uninstall_super
	$(MAKE) install_super

install_desktoprefresh: ${CONFIG_ARTIFACTS}
	$(MAKE) -C ${BUILD} $@

uninstall_desktoprefresh: ${CONFIG_ARTIFACTS} # uninstall graphical settings, takes effect immediately
	$(MAKE) -C ${BUILD} $@

upgrade_desktoprefresh: # install/upgrade graphical settings, takes effect immediately
	$(MAKE) uninstall_desktoprefresh
	$(MAKE) install_desktoprefresh

mksudo: ${CONFIG_ARTIFACTS} # set current user as system administrator
	$(MAKE) -C ${BUILD} $@

rmsudo: ${CONFIG_ARTIFACTS} # unset current user as system administrator
	$(MAKE) -C ${BUILD} $@

import: # import changes to the currently installed scripts/config files into the repository
	$(MAKE) -C ${BUILD} $@

tags:: # create tags
	ctags -R --extra=+f --language-force=sh --exclude=tgt --exclude=tmp --exclude=.git .

clean: # remove built targets
	rm -rf tgt tmp

mrproper: clean # remove everything generate by any build target from the project's directory
	rm -f config.sh tags

# code is ugly, format is pretty
# first, we find all "hard-coded" targets
# then, remove everything that doesn't have a comment and remove everything
# but the target and comment themselves. ':' marks the beginning of explanation.
# then, fold it tightly such that the terminal doesn't fold it
# then append ' :' to folded lines so that the formatter undestands its part of
# the explanation column
# then format it to columns
# see? it wasn't that bad... right? right?!
help: # this message
	@egrep '^[a-zA-Z0-9_]*::?( |$$)' ${THIS_MAKEFILE} |	\
		sed '/:[^#]*$$/d; s/:.*# /:/' |			\
		fold -s -w 65 |					\
		sed 's/\(^[^:]*$$\)/ :&/' |			\
		column -s : -t

test: # dump configuration
	$(MAKE) -C ${BUILD} $@

progs: # install set of progs required for this project and in general for power users
	$(MAKE) -C ${BUILD} $@

${ALL_CONFIG_VARS}: ${CONFIG_FILE} ${BUILD}/config_allvars.sh ${BUILD}/config_dump_vals.sh
	bash ${BUILD}/config_dump_vals.sh \
		${BUILD}/config_allvars.sh ${CONFIG_FILE} > $@.tmp
	mv $@.tmp $@

${CONFIG_FILE}: ${DEFAULT_CONFIG_FILE} ${USER_CONFIG_VARS}
	bash ${BUILD}/touch_config.sh $@ ${DEFAULT_CONFIG_FILE} ${USER_CONFIG_VARS} ${TMP_CFG}

${SED_SCRIPT}: ${ALL_CONFIG_VARS} ${BUILD}/make_sed_commands.sh
	${BUILD}/make_sed_commands.sh ${ALL_CONFIG_VARS} > ${SED_SCRIPT}

${USER_CONFIG_VARS}: ${DEFAULT_CONFIG_FILE} ${THIS_MAKEFILE}
	mkdir -p $(dir $@)
	grep -v '+=' ${DEFAULT_CONFIG_FILE} | cut -d= -f1 -s | sort -u > $@

.PHONY: clean build all help test config mrproper
.PHONY: install_luser uninstall_luser upgrade_luser
.PHONY: install_super uninstall_super upgrade_super mksudo rmsudo
.PHONY: install_desktoprefresh uninstall_desktoprefresh upgrade_desktoprefresh
