# at some point, your workplace WILL force you to work on a mac.
# the mac has OLD unix utils.
# make sure the build & install process can work with these old unit utils,
# so that they can automatically install modern unix utils.

export PROJECT	:= usr_scripts
THIS_MAKEFILE	:= $(firstword ${MAKEFILE_LIST})
BUILD 		:= ./build
CONFIG_FILE	:= config.sh
TMP_CFG		:= tmp/cfg
VALID_CONFIG	:= ${TMP_CFG}/valid_config
SED_SCRIPT	:= ${TMP_CFG}/replace_vars.sed
DEFAULT_CONFIG_FILE	:= ${BUILD}/default_config.sh
USER_CONFIG_VARS	:= ${TMP_CFG}/config_vars.user.txt
ALL_CONFIG_VARS		:= ${TMP_CFG}/config_vars.all.sh

EFFECTIVE_CONF	:= $(shell if [ -f ${CONFIG_FILE} ]; then echo ${CONFIG_FILE}; else echo ${BUILD}/default_config.sh; fi)

CONFIG_DESKTOP	:= $(shell ${BUILD}/config_query.sh ${EFFECTIVE_CONF} CONFIG_DESKTOP)
CONFIG_MINT	:= $(shell ${BUILD}/config_query.sh ${EFFECTIVE_CONF} CONFIG_MINT)
CONFIG_VROOT	:= $(shell ${BUILD}/config_query.sh ${EFFECTIVE_CONF} CONFIG_VROOT)
CONFIG_INSTALL_FIREFOX	:= $(shell ${BUILD}/config_query.sh ${EFFECTIVE_CONF} CONFIG_INSTALL_FIREFOX)
CONFIG_INSTALL_CHROMIUM	:= $(shell ${BUILD}/config_query.sh ${EFFECTIVE_CONF} CONFIG_INSTALL_CHROMIUM)

findsrc = $(shell find $(addprefix src/,$1) -type f)
insrc = $(patsubst src/%, %, $1)
srcfiles = $(call insrc,$(call findsrc,$1))

LUSER_FILES :=			\
	bin/urlencode bin/urldecode \
	bin/pssh		\
	bin/quien		\
	bin/allfiles		\
	bin/ascii		\
	bin/base		\
	bin/binary		\
	bin/blockgrep		\
	bin/build		\
	bin/calc		\
	bin/callchain		\
	bin/cmd_exists		\
	bin/color		\
	bin/color_echo		\
	bin/color_stderr	\
	bin/colsort		\
	bin/dec			\
	bin/errcho		\
	bin/errno		\
	bin/country		\
	bin/httpc		\
	bin/extract		\
	bin/ff			\
	bin/findgrep		\
	bin/freplace		\
	bin/getbit		\
	bin/git-alog		\
	bin/git-diff-diff	\
	bin/git-diff-log	\
	bin/git-einit		\
	bin/git-make-patchset	\
	bin/git-push-rewrite	\
	bin/gstack		\
	bin/highlight		\
	bin/hton		\
	bin/killgrep		\
	bin/ldir		\
	bin/log			\
	bin/lspkg		\
	bin/make.debug		\
	bin/mfilter		\
	bin/msg			\
	bin/num2ip		\
	bin/pig			\
	bin/psgrep		\
	bin/randomstr		\
	bin/remote_execute.sh	\
	bin/signum		\
	bin/stacklines		\
	bin/strlen		\
	bin/supported		\
	bin/sys			\
	bin/system_arch		\
	bin/system_bits		\
	bin/system_cpu_count	\
	bin/system_ip		\
	bin/system_platform	\
	bin/system_user		\
	bin/system_version	\
	bin/termset		\
	bin/timestamp		\
	bin/vmore		\
	bin/invim		\
	bin/mktags		\
	bin/getenv		\
	bin/wless		\
	etc/bash_completion	\
	etc/inputrc		\
	etc/bashrc		\
	etc/bashrc.user		\
	etc/colordiffrc		\
	etc/colorsrc		\
	etc/gdbinit		\
	etc/gitconfig		\
	etc/gitignore		\
	etc/screenrc		\
	etc/vimrc		\
	etc/htoprc		\
	share/countries.csv	\
	share/http.db		\
$(call srcfiles,		\
	lib/vim			\
)

ifeq (${CONFIG_DESKTOP},true)
DESKTOP_FILES :=		\
	bin/cb			\
	bin/mw			\
	bin/dlookup		\
	bin/icat		\
	bin/gui			\
	bin/myip		\
	bin/permute		\
	bin/stopwatch		\
	bin/xvim		\
	bin/vm			\
	bin/mvspc		\
	bin/gt			\
	etc/xdefaults		\
	share/hebrew.txt.xz	\
	etc/desktop/gnome2/genius	\
	etc/desktop/config/mimeapps.list \
$(call srcfiles,			\
	etc/desktop/config/caja		\
	etc/desktop/config/audacious	\
	etc/desktop/config/geeqie	\
	etc/desktop/config/kupfer	\
	etc/desktop/config/vlc		\
	lib/urxvt/			\
)
LUSER_FILES += ${DESKTOP_FILES}
endif

ifeq (${CONFIG_MINT},true)
MINT_FILES :=			\
	etc/user-dirs.dirs
LUSER_FILES += ${MINT_FILES}
endif

SUPER_FILES :=			\
	etc/rsyslog.conf	\
	etc/grub		\
	etc/sudoers		\
	etc/sysctl.conf		\
$(call srcfiles,		\
	sbin/			\
)

DESKTOPREFRESH_FILES :=				\
	etc/dconf/dconf_user.touchpad.ini	\
	etc/dconf/dconf_user.monitor2.ini	\
	etc/dconf/dconf_user.desktop.media.ini	\
	etc/dconf/dconf_user.desktop.windows.ini \
	etc/dconf/dconf_user.touchpad.media.ini	\
	etc/dconf/dconf_user.touchpad.windows.ini \
	etc/dconf/dconf_user.ini

ALL_FILES := ${LUSER_FILES} ${SUPER_FILES} ${DESKTOPREFRESH_FILES}

all: build # equivalent to build

build: $(addprefix tgt/,${ALL_FILES}) # create configured scripts/config files in tgt/, ready to be installed

config: ${CONFIG_FILE} ${BUILD}/config_dump_vals.sh ${ALL_CONFIG_VARS} # upgrade or create a config file from the default settings
	@echo --------------------------------
	@echo config file written to '${CONFIG_FILE}'
	@echo please review the configuration:
	@echo --------------------------------
	@bash ${BUILD}/config_dump_vals.sh ${CONFIG_FILE}

${SED_SCRIPT}: ${ALL_CONFIG_VARS} ${BUILD}/make_sed_commands.sh
	${BUILD}/make_sed_commands.sh ${ALL_CONFIG_VARS} > ${SED_SCRIPT}

tgt:
	mkdir $@

# mac note: the sed script is coupled with the specific version of sed that is
# bundled with the OS, so if we're e.g. in upgrade_luser, 'sed' that's in the
# path may be the one we just installed, rather than the bundled one, so we must
# explicitly ask for the bundled one.
tmpfile = $(subst tgt/,tmp/,$1)
tgt/%: src/% ${USER_CONFIG_VARS} ${SED_SCRIPT} tgt
	mkdir -p $(dir $@) $(dir $(call tmpfile,$@))
	cp -f $< "$(call tmpfile,$@)"
	${BUILD}/binary $@ || /usr/bin/sed -i.bak -f ${SED_SCRIPT} "$(call tmpfile,$@)"
	mv "$(call tmpfile,$@)" $@

${CONFIG_VROOT}:
	mkdir $@

${CONFIG_VROOT}/bin/%: tgt/bin/% ${CONFIG_VROOT}
	${BUILD}/install1 exec $< $@

${CONFIG_VROOT}/sbin/%: tgt/sbin/% ${CONFIG_VROOT}
	${BUILD}/install1 exec $< $@

${CONFIG_VROOT}/etc/%: tgt/etc/% ${CONFIG_VROOT}
	${BUILD}/install1 data $< $@

${CONFIG_VROOT}/lib/%: tgt/lib/% ${CONFIG_VROOT}
	${BUILD}/install1 data $< $@

${CONFIG_VROOT}/share/%: tgt/share/% ${CONFIG_VROOT}
	${BUILD}/install1 data $< $@

${VALID_CONFIG}: ${CONFIG_FILE}
	rm -rf tgt tmp
	bash -e $<
	mkdir -p $(dir $@)
	touch $@

${CONFIG_FILE}: ${DEFAULT_CONFIG_FILE} ${USER_CONFIG_VARS}
	bash ${BUILD}/touch_config.sh $@ $^ ${TMP_CFG}

${USER_CONFIG_VARS}: ${DEFAULT_CONFIG_FILE} ${THIS_MAKEFILE}
	mkdir -p $(dir $@)
	grep -v '+=' $< | cut -d= -f1 -s | sort -u > $@

${ALL_CONFIG_VARS}: ${CONFIG_FILE} ${BUILD}/config_allvars.sh ${BUILD}/config_dump_vals.sh
	bash ${BUILD}/config_dump_vals.sh \
		${BUILD}/config_allvars.sh ${CONFIG_FILE} > $@.tmp
	mv $@.tmp $@

u_suffix = $(word 2, $(subst _, ,$1))
INSTALLED_LUSER_FILES = $(addprefix ${CONFIG_VROOT}/,${LUSER_FILES})
INSTALLED_SUPER_FILES = $(addprefix ${CONFIG_VROOT}/,${SUPER_FILES})
INSTALLED_DESKTOPREFRESH_FILES = $(addprefix ${CONFIG_VROOT}/,${DESKTOPREFRESH_FILES})

install_luser: ${ALL_CONFIG_VARS} ${INSTALLED_LUSER_FILES}
	bash ${BUILD}/luser.sh install ${ALL_CONFIG_VARS}
	${BUILD}/vrootdir mkversion ${CONFIG_VROOT} $@ ${CONFIG_FILE}

uninstall_luser: ${ALL_CONFIG_VARS} # uninstall scripts and config of current user
	bash ${BUILD}/luser.sh uninstall ${ALL_CONFIG_VARS}
	rm -f ${INSTALLED_LUSER_FILES}
	${BUILD}/vrootdir rmversion ${CONFIG_VROOT} $@

upgrade_luser: # install/upgrade scripts and config of current user
	$(MAKE) uninstall_luser
	$(MAKE) install_luser

install_super: ${ALL_CONFIG_VARS} ${INSTALLED_SUPER_FILES}
	bash ${BUILD}/super.sh install ${ALL_CONFIG_VARS}
	${BUILD}/vrootdir mkversion ${CONFIG_VROOT} $@ ${CONFIG_FILE}

uninstall_super: ${ALL_CONFIG_VARS} # uninstall administrative scripts and config
	rm -f ${INSTALLED_SUPER_FILES}
	bash ${BUILD}/super.sh uninstall ${ALL_CONFIG_VARS}
	${BUILD}/vrootdir rmversion ${CONFIG_VROOT} $@

upgrade_super: # install/upgrade administrative scripts and config
	$(MAKE) uninstall_super
	$(MAKE) install_super

install_desktoprefresh: ${ALL_CONFIG_VARS} ${INSTALLED_DESKTOPREFRESH_FILES}
	bash ${BUILD}/luser.sh $@ ${ALL_CONFIG_VARS}
	${BUILD}/vrootdir mkversion ${CONFIG_VROOT} $@ ${CONFIG_FILE}

uninstall_desktoprefresh: ${ALL_CONFIG_VARS} # uninstall graphical settings, takes effect immediately
	rm -f ${INSTALLED_DESKTOPREFRESH_FILES}
	bash ${BUILD}/luser.sh $@ ${ALL_CONFIG_VARS}
	${BUILD}/vrootdir rmversion ${CONFIG_VROOT} $@

upgrade_desktoprefresh: # install/upgrade graphical settings, takes effect immediately
	$(MAKE) uninstall_desktoprefresh
	$(MAKE) install_desktoprefresh

mksudo: ${ALL_CONFIG_VARS} # set current user as system administrator
	${BUILD}/vrootdir mk ${CONFIG_VROOT}
	@echo root password required:
	su -c "bash ${BUILD}/super.sh $@ ${ALL_CONFIG_VARS}"

rmsudo: ${ALL_CONFIG_VARS} # unset current user as system administrator
	@echo root password required:
	su -c "bash ${BUILD}/super.sh $@ ${ALL_CONFIG_VARS}"
	${BUILD}/vrootdir rm ${CONFIG_VROOT}

import: ${CONFIG_FILE} tgt build # import changes to the currently installed scripts/config files into the repository
	# do it in reverse order such that it's easier to patch
	-(cd tgt && diff -ur ${CONFIG_VROOT} .) > tmp/$@.patch
	patch --directory=src --reverse -p0 --merge < tmp/$@.patch

tags:: # create tags
	ctags -R --extra=+f --language-force=sh --exclude=tgt --exclude=tmp --exclude=.git .

clean: # remove built targets
	rm -rf tgt tmp

mrproper: clean # remove everything generate by any build target from the project's directory
	rm -f config.sh tags

ifneq ($(shell which yum),)
progs: ${ALL_CONFIG_VARS} # install set of progs required for this project and in general for power users
	yum install epel-release
	yum install 		\
		dos2unix	\
		yq		\
		jq		\
		socat		\
		python36 python34-pip \
		moreutils	\
		man-db		\
		man-pages man-pages-overrides \
		htop		\
		tree		\
		net-tools	\
		m4		\
		ncurses ncurses-devel \
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
		gcc glibc-static \
		file		\
		gawk		\
		bc		\
		p7zip		\
		bzip2		\
		gzip		\
		xz		\
		tar		\
		openssh-clients	openssh-server \
		cscope		\
		ctags		\
		colordiff	\
		diffutils	\
		patch		\
		less		\
		util-linux	\
		vim		\
		git git-email	\
		bash-completion	bash-completion-extras \
		bash		\
		make
	if ${CONFIG_DESKTOP}; then yum install \
		xclip		\
		rxvt-unicode	\
	; fi
else
ifneq ($(shell which apt-get),)
progs: ${ALL_CONFIG_VARS}
	apt-get install 	\
		peco		\
		dos2unix	\
		html2text	\
		whois		\
		nodejs		\
		yq		\
		jq		\
		socat		\
		moreutils	\
		man-db		\
		htop		\
		tree		\
		whois		\
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
		tcl		\
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
		openssh-client openssh-server \
		cscope		\
		universal-ctags	\
		colordiff	\
		diffutils	\
		patch		\
		less		\
		procps		\
		findutils	\
		util-linux	\
		vim		\
		git		\
		bash-completion	\
		bash		\
		make
	if ${CONFIG_DESKTOP}; then apt-get install \
		fluid-soundfont-gm fluid-soundfont-gs timgm6mb-soundfont \
		id3v2		\
		retext		\
		geeqie		\
		vlc		\
		kupfer		\
		audacious	\
		easytag		\
		vim-gtk		\
		dict dictd dict-gcide \
		xclip		\
		rxvt-unicode	\
	; fi
	if ${CONFIG_DESKTOP} && ${CONFIG_INSTALL_FIREFOX}; then apt-get install \
		firefox		\
	; fi
	if ${CONFIG_DESKTOP} && ${CONFIG_INSTALL_CHROMIUM}; then apt-get install \
		chromium-browser \
	; fi
	if ${CONFIG_DESKTOP}; then \
		apt-get install cfv \
		|| apt-get install cksfv \
	; fi
	if ${CONFIG_DESKTOP}; then \
		apt-get install gnome-genius \
		|| apt-get install genius \
	; fi
	if ${CONFIG_DESKTOP}; then \
		rm -rf /tmp/$(PROJECT)/deb && \
		mkdir -p /tmp/$(PROJECT)/deb && \
		cd /tmp/$(PROJECT)/deb && \
		wget "https://remarkableapp.github.io/files/remarkable_1.87_all.deb" && \
		apt install ./* \
	; fi
	if ${CONFIG_MINT}; then apt-get install \
		dconf-cli	\
		mate-panel mate-panel-common \
		mate-applets mate-applets-common \
		mintmenu	\
	; fi
else
ifneq ($(shell which brew),)
progs: ${ALL_CONFIG_VARS}
	brew install 	\
		dos2unix	\
		html2text	\
		node		\
		python		\
		jq		\
		socat		\
		grep		\
		moreutils	\
		coreutils	\
		htop		\
		tree		\
		tcpdump		\
		wget		\
		lsof		\
		pstree		\
		cloc		\
		binutils	\
		tcl-tk		\
		curl		\
		nmap		\
		netcat		\
		screen		\
		gcc		\
		gawk		\
		gsed		\
		bc		\
		p7zip		\
		xz		\
		bzip2		\
		gzip		\
		openssh 	\
		cscope		\
		ctags		\
		colordiff	\
		diffutils	\
		less lesspipe	\
		findutils	\
		vim		\
		git		\
		bash-completion	\
		bash-git-prompt \
		bash		\
		make		\
		xclip		\
		iterm2
	if ${CONFIG_INSTALL_FIREFOX}; then brew install \
		firefox	\
	; fi
	if ${CONFIG_INSTALL_CHROMIUM}; then brew install \
		chromium	\
	; fi
endif
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
	@egrep '^[a-zA-Z0-9_]*::?( |$$)' ${THIS_MAKEFILE} |	\
		sed '/:[^#]*$$/d; s/:.*# /:/' |			\
		fold -s -w 65 |					\
		sed 's/\(^[^:]*$$\)/ :&/' |			\
		column -s : -t

test: ${CONFIG_FILE} ${ALL_CONFIG_VARS} ${SED_SCRIPT} # dump configuration
	@echo "luser files:"
	@echo "${LUSER_FILES}"
	@echo
	@echo "super files:"
	@echo "${SUPER_FILES}"
	@echo
	@echo "desktoprefresh files:"
	@echo "${DESKTOPREFRESH_FILES}"
	@echo
	@echo "all config vars:"
	@cat ${ALL_CONFIG_VARS}
	@echo
	@echo "config file:"
	@cat ${CONFIG_FILE}
	@echo
	@echo "sed script:"
	@cat ${SED_SCRIPT}

.PHONY: clean build all help test config mrproper
.PHONY: install_luser uninstall_luser upgrade_luser
.PHONY: install_super uninstall_super upgrade_super mksudo rmsudo
.PHONY: install_desktoprefresh uninstall_desktoprefresh upgrade_desktoprefresh
