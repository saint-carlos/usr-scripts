export PROJECT	:= usr_scripts
BUILD 		:= ./build
CONFIG_FILE	:= config.sh
TMP_CFG		:= tmp/cfg
VALID_CONFIG	:= ${TMP_CFG}/valid_config
DEFAULT_CONFIG_FILE	:= ${BUILD}/default_config.sh
ALL_CONFIG_VARS		:= ${TMP_CFG}/config_vars.all.txt
CURRENT_CONFIG_VARS	:= ${TMP_CFG}/config_vars.current.txt

FILES := $(patsubst src/%, %, $(wildcard \
	src/bin/*			\
	src/sbin/*			\
	src/etc/*			\
	src/lib/vim/*/*.*		\
	src/lib/vim/*/*/*.*		\
	src/lib/urxvt/*			\
	src/share/*			\
))

DESKTOP_FILES :=		\
	bin/dlookup		\
	share/hebrew.txt.xz	\
	bin/icat		\
	bin/myip		\
	bin/permute		\
	bin/stopwatch		\
	bin/xvim		\
	etc/xdefaults		\
	bin/vm			\
	bin/mvspc		\
	bin/lspkg		\
	$(patsubst src/%, %, $(wildcard	\
		src/lib/urxvt/*		\
	))
ifeq (false,$(shell ${BUILD}/config.sh ${CONFIG_FILE} CONFIG_DESKTOP))
	CONFIG_DESKTOP := false
	FILES := $(filter-out ${DESKTOP_FILES},${FILES})
else
	CONFIG_DESKTOP := true
endif

PD_FILES :=			\
	bin/git-check-patchset	\
	etc/bash_completion.pd
ifeq (false,$(shell ${BUILD}/config.sh ${CONFIG_FILE} CONFIG_PD))
	FILES := $(filter-out ${PD_FILES},${FILES})
endif

SED_COMMANDS = $(shell ${BUILD}/make_sed_commands.sh ${CONFIG_FILE})

all: build # equivalent to build

build: $(addprefix tgt/,${FILES}) # create configured scripts/config files in tgt/, ready to be installed

config: ${VALID_CONFIG} # update or create a config file from the default settings

basedir = $(shell basename $(dir $1))
tmpdir = tmp/$(call basedir,$1)

tgt/%: src/% ${BUILD}/make_sed_commands.sh ${CONFIG_FILE} ${VALID_CONFIG}
	mkdir -p $(dir $@) $(call tmpdir,$@)
	cp -f $< $(call tmpdir,$@)
	${BUILD}/binary $@ || sed -i "${SED_COMMANDS}" $(call tmpdir,$@)/$(notdir $@)
	mv $(call tmpdir,$@)/$(notdir $@) $@

${VALID_CONFIG}: ${CONFIG_FILE}
	rm -rf tgt tmp
	sh -e $<
	mkdir -p $(dir $@)
	touch $@

${CONFIG_FILE}: ${DEFAULT_CONFIG_FILE} ${ALL_CONFIG_VARS}
	: > ${CURRENT_CONFIG_VARS}
	test ! -f $@ || cut -d= -f1 $@ | sort > ${CURRENT_CONFIG_VARS}
	comm -23 ${ALL_CONFIG_VARS} ${CURRENT_CONFIG_VARS} | xargs -L 1 -I @ grep ^@= ${DEFAULT_CONFIG_FILE} > ${TMP_CFG}/config.unsorted
	: > ${TMP_CFG}/config.dependent
	grep '\$$.*CONFIG' ${TMP_CFG}/config.unsorted > ${TMP_CFG}/config.dependent || true
	comm -23 ${TMP_CFG}/config.unsorted ${TMP_CFG}/config.dependent > ${TMP_CFG}/config.tmp
	cat ${TMP_CFG}/config.tmp ${TMP_CFG}/config.dependent >> $@

${ALL_CONFIG_VARS}: ${DEFAULT_CONFIG_FILE}
	mkdir -p $(dir $@)
	cut -d= -f1 $< | sort > $@

install: build tgt ${CONFIG_FILE} # install configured scripts/config files from tgt/
	${BUILD}/install.sh ${CONFIG_FILE} tgt ${FILES}

install_user: build tgt ${CONFIG_FILE} # update the user configuration to accommodate installed scripts/config files
	${BUILD}/install_user.sh ${CONFIG_FILE}

install_all: install install_user # install configured scripts/config files and update the user configuration to accommodate them

uninstall: ${CONFIG_FILE} # remove the scripts/config files from the user configuration and delete them
	${BUILD}/uninstall.sh ${CONFIG_FILE}

update: uninstall install_all # update the user configuration from the repository (equivalent to uninstall and then install_all)

import: ${CONFIG_FILE} tgt build # import changes to the currently installed scripts/config files into the repository
	# do it in reverse order such that it's easier to patch
	(eval $$(grep CONFIG_VROOT ${CONFIG_FILE}) && cd tgt && (diff -ur $$CONFIG_VROOT . || true)) > tmp/$@.patch
	patch --directory=src --reverse -p0 --merge < tmp/$@.patch

tags:: # create tags
	ctags -R --language-force=sh --exclude tgt .

clean: # remove built targets
	rm -rf tgt tmp

mrproper: clean # remove everything generate by any build target from the project's directory
	rm -f config.sh tags

ifneq ($(shell which yum),)
progs: # install set of progs required for this project and in general for power users
	yum install 		\
		epel-release	\
		htop		\
		tree		\
		net-tools	\
		man-pages	\
		m4		\
		ncurses-devel	\
		git-email	\
		autoconf	\
		libtool		\
		flex		\
		bison		\
		gpg		\
		tcpdump		\
		wget		\
		perf		\
		sparse		\
		valgrind	\
		time		\
		lsof		\
		psmisc		\
		cloc		\
		elfutils	\
		binutils	\
		dwarves		\
		tcl		\
		curl		\
		nmap		\
		nc		\
		traceroute	\
		screen		\
		ltrace		\
		strace		\
		gdb		\
		gcc		\
		glibc-static	\
		file		\
		gawk		\
		bc		\
		ncurses		\
		p7zip		\
		bzip2		\
		gzip		\
		xz		\
		tar		\
		bash-completion	\
		openssh-clients	\
		openssh-server	\
		cscope		\
		ctags		\
		diffutils	\
		patch		\
		less		\
		util-linux	\
		vim		\
		git		\
		bash		\
		make
	if ${CONFIG_DESKTOP}; then yum install \
		rxvt-unicode	\
	; fi
else
ifneq ($(shell which apt-get),)
progs:
	apt-get install 	\
		htop		\
		tree		\
		tcpdump		\
		wget		\
		linux-tools-common \
		sparse		\
		valgrind	\
		time		\
		lsof		\
		psmisc		\
		cloc		\
		elfutils	\
		binutils	\
		dwarves		\
		tcl8.5		\
		curl		\
		nmap		\
		netcat-openbsd	\
		traceroute	\
		screen		\
		ltrace		\
		strace		\
		pstack		\
		gdb		\
		gcc		\
		file		\
		gawk		\
		bc		\
		ncurses-bin	\
		p7zip		\
		xz-utils	\
		bzip2		\
		gzip		\
		tar		\
		bash-completion	\
		openssh-client	\
		openssh-server	\
		cscope		\
		exuberant-ctags	\
		diffutils	\
		patch		\
		less		\
		util-linux	\
		vim		\
		git		\
		bash		\
		make
	if ${CONFIG_DESKTOP}; then apt-get install \
		dict dictd dict-gcide \
		rxvt-unicode	\
	; fi
endif
endif

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
	@egrep '^[a-zA-Z0-9_]*::?( |$$)' ${MAKEFILE_LIST} |	\
		sed '/:[^#]*$$/d; s/:.*# /:/' |			\
		fold -s -w 65 |					\
		sed 's/\(^[^:]*$$\)/ :&/' |			\
		column -s : -t

test: ${ALL_CONFIG_VARS} # dump configuration
	@echo "files:"
	@echo "${FILES}"
	@echo
	@echo "all config vars:"
	@cat ${ALL_CONFIG_VARS}
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
