# this makefile assumes configuration has already been performed, and that
# CONFIG_FILE, ALL_CONFIG_VARS, SED_SCRIPT have been set up appropriately and
# exported to the environment.

PREFIX=..
dirpivot = $(addprefix ${PREFIX}/,$1)

export PROJECT	:= usr_scripts
BUILD 		:= .
CONFIG_FILE 	:= $(call dirpivot,${CONFIG_FILE})
ALL_CONFIG_VARS	:= $(call dirpivot,${ALL_CONFIG_VARS})
SED_SCRIPT	:= $(call dirpivot,${SED_SCRIPT})

EFFECTIVE_CONF	:= ${ALL_CONFIG_VARS}

CONFIG_DESKTOP	:= $(shell ${BUILD}/config_query.sh ${EFFECTIVE_CONF} CONFIG_DESKTOP)
CONFIG_MINT	:= $(shell ${BUILD}/config_query.sh ${EFFECTIVE_CONF} CONFIG_MINT)
CONFIG_VROOT	:= $(shell ${BUILD}/config_query.sh ${EFFECTIVE_CONF} CONFIG_VROOT)
CONFIG_INSTALL_FIREFOX	:= $(shell ${BUILD}/config_query.sh ${EFFECTIVE_CONF} CONFIG_INSTALL_FIREFOX)
CONFIG_INSTALL_CHROMIUM	:= $(shell ${BUILD}/config_query.sh ${EFFECTIVE_CONF} CONFIG_INSTALL_CHROMIUM)

findsrc = $(shell find $(addprefix ${PREFIX}/src/,$1) -type f)
insrc = $(patsubst ${PREFIX}/src/%, %, $1)
srcfiles = $(call insrc,$(call findsrc,$1))

LUSER_FILES :=			\
	bin/urlencode bin/urldecode \
	bin/pssh		\
	bin/quien		\
	bin/allfiles		\
	bin/ascii		\
	bin/ascii.py		\
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
	bin/bin2ascii		\
	bin/ascii2bin		\
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

build: $(addprefix ${PREFIX}/tgt/,${ALL_FILES})

${PREFIX}/tgt:
	mkdir -p $@

# mac note: the sed script is coupled with the specific version of sed that is
# bundled with the OS, so if we're e.g. in upgrade_luser, 'sed' that's in the
# path may be the one we just installed, rather than the bundled one, so we must
# explicitly ask for the bundled one.
tmpfile = $(subst /tgt/,/tmp/,$1)
${PREFIX}/tgt/%: ${PREFIX}/src/% ${SED_SCRIPT}
	mkdir -p $(dir $@) $(dir $(call tmpfile,$@))
	cp -f $< "$(call tmpfile,$@)"
	${BUILD}/binary $@ || /usr/bin/sed -i.bak -f ${SED_SCRIPT} "$(call tmpfile,$@)"
	mv "$(call tmpfile,$@)" $@

${CONFIG_VROOT}:
	${BUILD}/vrootdir mk $@

${CONFIG_VROOT}/bin/%: ${PREFIX}/tgt/bin/% ${CONFIG_VROOT}
	${BUILD}/install1 exec $< $@

${CONFIG_VROOT}/sbin/%: ${PREFIX}/tgt/sbin/% ${CONFIG_VROOT}
	${BUILD}/install1 exec $< $@

${CONFIG_VROOT}/etc/%: ${PREFIX}/tgt/etc/% ${CONFIG_VROOT}
	${BUILD}/install1 data $< $@

${CONFIG_VROOT}/lib/%: ${PREFIX}/tgt/lib/% ${CONFIG_VROOT}
	${BUILD}/install1 data $< $@

${CONFIG_VROOT}/share/%: ${PREFIX}/tgt/share/% ${CONFIG_VROOT}
	${BUILD}/install1 data $< $@

INSTALLED_LUSER_FILES = $(addprefix ${CONFIG_VROOT}/,${LUSER_FILES})
INSTALLED_SUPER_FILES = $(addprefix ${CONFIG_VROOT}/,${SUPER_FILES})
INSTALLED_DESKTOPREFRESH_FILES = $(addprefix ${CONFIG_VROOT}/,${DESKTOPREFRESH_FILES})

install_luser: ${ALL_CONFIG_VARS} ${CONFIG_FILE} ${INSTALLED_LUSER_FILES}
	bash ${BUILD}/luser.sh install ${ALL_CONFIG_VARS}
	${BUILD}/vrootdir mkversion ${CONFIG_VROOT} $@ ${CONFIG_FILE}

uninstall_luser: ${ALL_CONFIG_VARS}
	bash ${BUILD}/luser.sh uninstall ${ALL_CONFIG_VARS}
	rm -f ${INSTALLED_LUSER_FILES}
	${BUILD}/vrootdir rmversion ${CONFIG_VROOT} $@

install_super: ${ALL_CONFIG_VARS} ${CONFIG_FILE} ${INSTALLED_SUPER_FILES}
	bash ${BUILD}/super.sh install ${ALL_CONFIG_VARS}
	${BUILD}/vrootdir mkversion ${CONFIG_VROOT} $@ ${CONFIG_FILE}

uninstall_super: ${ALL_CONFIG_VARS}
	rm -f ${INSTALLED_SUPER_FILES}
	bash ${BUILD}/super.sh uninstall ${ALL_CONFIG_VARS}
	${BUILD}/vrootdir rmversion ${CONFIG_VROOT} $@

install_desktoprefresh: ${ALL_CONFIG_VARS} ${CONFIG_FILE} ${INSTALLED_DESKTOPREFRESH_FILES}
	bash ${BUILD}/luser.sh $@ ${ALL_CONFIG_VARS}
	${BUILD}/vrootdir mkversion ${CONFIG_VROOT} $@ ${CONFIG_FILE}

uninstall_desktoprefresh: ${ALL_CONFIG_VARS}
	rm -f ${INSTALLED_DESKTOPREFRESH_FILES}
	bash ${BUILD}/luser.sh $@ ${ALL_CONFIG_VARS}
	${BUILD}/vrootdir rmversion ${CONFIG_VROOT} $@

mksudo: ${ALL_CONFIG_VARS}
	${BUILD}/vrootdir mk ${CONFIG_VROOT}
	@echo root password required:
	su -c "bash ${BUILD}/super.sh $@ ${ALL_CONFIG_VARS}"

rmsudo: ${ALL_CONFIG_VARS}
	@echo root password required:
	su -c "bash ${BUILD}/super.sh $@ ${ALL_CONFIG_VARS}"
	${BUILD}/vrootdir rm ${CONFIG_VROOT}

import: ${PREFIX}/tgt build
	# do it in reverse order such that it's easier to patch
	-(cd tgt && diff -ur ${CONFIG_VROOT} .) > tmp/$@.patch
	patch --directory=src --reverse -p0 --merge < tmp/$@.patch

test:
	@echo "luser files:"
	@printf '%s\n' ${LUSER_FILES}
	@echo
	@echo "super files:"
	@printf '%s\n' ${SUPER_FILES}
	@echo
	@echo "desktoprefresh files:"
	@printf '%s\n' ${DESKTOPREFRESH_FILES}
	@echo
	@echo "all config vars '${ALL_CONFIG_VARS}':"
	-@cat ${ALL_CONFIG_VARS}
	@echo
	@echo "config file '${CONFIG_FILE}':"
	-@cat ${CONFIG_FILE}
	@echo
	@echo "sed script '${SED_SCRIPT}':"
	-@cat ${SED_SCRIPT}

ifneq ($(shell which yum),)
progs: ${ALL_CONFIG_VARS}
	sudo yum install epel-release
	sudo yum install 	\
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
	if ${CONFIG_DESKTOP}; then sudo yum install \
		xclip		\
		rxvt-unicode	\
	; fi
else
ifneq ($(shell which apt-get),)
progs: ${ALL_CONFIG_VARS}
	sudo apt-get install 	\
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
	if ${CONFIG_DESKTOP}; then sudo apt-get install \
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
		sudo apt-get install cfv \
		|| sudo apt-get install cksfv \
	; fi
	if ${CONFIG_DESKTOP}; then \
		sudo apt-get install gnome-genius \
		|| sudo apt-get install genius \
	; fi
	if ${CONFIG_DESKTOP}; then \
		rm -rf /tmp/$(PROJECT)/deb && \
		mkdir -p /tmp/$(PROJECT)/deb && \
		cd /tmp/$(PROJECT)/deb && \
		wget "https://remarkableapp.github.io/files/remarkable_1.87_all.deb" && \
		apt install ./* \
	; fi
	if ${CONFIG_MINT}; then sudo apt-get install \
		dconf-cli	\
		mate-panel mate-panel-common \
		mate-applets mate-applets-common \
		mintmenu	\
	; fi
else
ifneq ($(shell which brew),)
progs: ${ALL_CONFIG_VARS}
	brew install 	\
		whois		\
		openssl@1.1	\
		tcptraceroute	\
		watch		\
		dos2unix	\
		html2text	\
		node		\
		python		\
		jq yq		\
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
		gnu-sed		\
		gnu-tar		\
		gnu-time	\
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
		gpatch		\
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

.PHONY: build
.PHONY: install_luser uninstall_luser upgrade_luser
.PHONY: install_super uninstall_super upgrade_super mksudo rmsudo
.PHONY: install_desktoprefresh uninstall_desktoprefresh upgrade_desktoprefresh
