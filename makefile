export PROJECT	:= usr_scripts
THIS_MAKEFILE	:= $(firstword ${MAKEFILE_LIST})
BUILD 		:= ./build
CONFIG_FILE	:= config.sh
TMP_CFG		:= tmp/cfg
VALID_CONFIG	:= ${TMP_CFG}/valid_config
DEFAULT_CONFIG_FILE	:= ${BUILD}/default_config.sh
ALL_CONFIG_VARS		:= ${TMP_CFG}/config_vars.all.txt

EFFECTIVE_CONF	:= $(shell if [ -f ${CONFIG_FILE} ]; then echo ${CONFIG_FILE}; else echo ${BUILD}/default_config.sh; fi)

CONFIG_DESKTOP	:= $(shell ${BUILD}/config_query.sh ${EFFECTIVE_CONF} CONFIG_DESKTOP)
CONFIG_MINT	:= $(shell ${BUILD}/config_query.sh ${EFFECTIVE_CONF} CONFIG_MINT)
CONFIG_VROOT	:= $(shell ${BUILD}/config_query.sh ${EFFECTIVE_CONF} CONFIG_VROOT)

findsrc = $(shell find $(addprefix src/,$1) -type f)
insrc = $(patsubst src/%, %, $1)
srcfiles = $(call insrc,$(call findsrc,$1))

LUSER_FILES :=			\
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
	bin/errcho		\
	bin/errno		\
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
	bin/parallelize		\
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
	etc/bash_completion	\
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
	share/http.db		\
$(call srcfiles,		\
	lib/vim/		\
)

ifeq (${CONFIG_DESKTOP},true)
DESKTOP_FILES :=		\
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
$(call srcfiles,		\
	sbin/			\
)

DESKTOPREFRESH_FILES :=		\
	etc/dconf_user.ini	\
	etc/dconf_user.2.ini	\

ALL_FILES := ${LUSER_FILES} ${SUPER_FILES} ${DESKTOPREFRESH_FILES}
SED_COMMANDS = $(shell ${BUILD}/make_sed_commands.sh ${CONFIG_FILE})

all: build # equivalent to build

build: $(addprefix tgt/,${ALL_FILES}) # create configured scripts/config files in tgt/, ready to be installed

config: ${VALID_CONFIG} # upgrade or create a config file from the default settings
	@echo --------------------------------
	@echo config file written to '${CONFIG_FILE}'
	@echo please review the configuration:
	@echo --------------------------------
	@bash ${BUILD}/config_dump_vals.sh ${CONFIG_FILE}

tmpfile = $(subst tgt/,tmp/,$1)
tgt/%: src/% ${BUILD}/make_sed_commands.sh ${ALL_CONFIG_VARS} ${CONFIG_FILE}
	mkdir -p $(dir $@) $(dir $(call tmpfile,$@))
	cp -f $< "$(call tmpfile,$@)"
	${BUILD}/binary $@ || sed -i "${SED_COMMANDS}" "$(call tmpfile,$@)"
	mv "$(call tmpfile,$@)" $@

define mkvroot =
	mkdir -p ${CONFIG_VROOT}
endef
define rmvroot =
	[ ! -d "${CONFIG_VROOT}" ] || find "${CONFIG_VROOT}" -type d -empty -delete
endef

define installexec =
	mkdir -p $(dir $@)
	install -m 755 -D $< $@
endef
define installdata =
	mkdir -p $(dir $@)
	install -m 644 -D $< $@
endef

${CONFIG_VROOT}:
	mkdir $@

${CONFIG_VROOT}/bin/%: tgt/bin/% ${CONFIG_VROOT}
	$(installexec)

${CONFIG_VROOT}/sbin/%: tgt/sbin/% ${CONFIG_VROOT}
	$(installexec)

${CONFIG_VROOT}/etc/%: tgt/etc/% ${CONFIG_VROOT}
	$(installdata)

${CONFIG_VROOT}/lib/%: tgt/lib/% ${CONFIG_VROOT}
	$(installdata)

${CONFIG_VROOT}/share/%: tgt/share/% ${CONFIG_VROOT}
	$(installdata)

${VALID_CONFIG}: ${CONFIG_FILE}
	rm -rf tgt tmp
	bash -e $<
	mkdir -p $(dir $@)
	touch $@

${CONFIG_FILE}: ${DEFAULT_CONFIG_FILE} ${ALL_CONFIG_VARS}
	bash ${BUILD}/touch_config.sh $@ $^ ${TMP_CFG}

${ALL_CONFIG_VARS}: ${DEFAULT_CONFIG_FILE} ${THIS_MAKEFILE}
	mkdir -p $(dir $@)
	grep -v '+=' $< | cut -d= -f1 -s | sort -u > $@

u_suffix = $(word 2, $(subst _, ,$1))
define mkversion =
	cp ${CONFIG_FILE} "${CONFIG_VROOT}/config-$(call u_suffix,$@)"
	git rev-parse HEAD > "${CONFIG_VROOT}/version-$(call u_suffix,$@)"
endef
define rmversion =
	rm -f "${CONFIG_VROOT}/version-$(call u_suffix,$@)"
	rm -f "${CONFIG_VROOT}/config-$(call u_suffix,$@)"
	$(rmvroot)
endef

INSTALLED_LUSER_FILES = $(addprefix ${CONFIG_VROOT}/,${LUSER_FILES})
INSTALLED_SUPER_FILES = $(addprefix ${CONFIG_VROOT}/,${SUPER_FILES})
INSTALLED_DESKTOPREFRESH_FILES = $(addprefix ${CONFIG_VROOT}/,${DESKTOPREFRESH_FILES})

install_luser: ${CONFIG_FILE} ${INSTALLED_LUSER_FILES}
	bash ${BUILD}/luser.sh install ${CONFIG_FILE}
	$(mkversion)

uninstall_luser: # uninstall scripts and config of current user
	bash ${BUILD}/luser.sh uninstall ${CONFIG_FILE}
	rm -f ${INSTALLED_LUSER_FILES}
	$(rmversion)

upgrade_luser: uninstall_luser install_luser # install/upgrade scripts and config of current user

install_super: ${CONFIG_FILE} ${INSTALLED_SUPER_FILES}
	bash ${BUILD}/super.sh install ${CONFIG_FILE}
	$(mkversion)

uninstall_super: # uninstall administrative scripts and config
	rm -f ${INSTALLED_SUPER_FILES}
	bash ${BUILD}/super.sh uninstall ${CONFIG_FILE}
	$(rmversion)

upgrade_super: uninstall_super install_super # install/upgrade administrative scripts and config

install_desktoprefresh: ${CONFIG_FILE} ${INSTALLED_DESKTOPREFRESH_FILES}
	bash ${BUILD}/luser.sh $@ ${CONFIG_FILE}
	$(mkversion)

uninstall_desktoprefresh: # uninstall graphical settings, takes effect immediately
	rm -f ${INSTALLED_DESKTOPREFRESH_FILES}
	bash ${BUILD}/luser.sh $@ ${CONFIG_FILE}
	$(rmversion)

upgrade_desktoprefresh: uninstall_desktoprefresh install_desktoprefresh # install/upgrade graphical settings, takes effect immediately

install_desktopinit: ${CONFIG_FILE} # initialize desktop-related applications, can be done only if not already initialized
	bash ${BUILD}/luser.sh $@ ${CONFIG_FILE}

mksudo: # set current user as system administrator
	$(mkvroot)
	@echo root password required:
	su -c "bash ${BUILD}/super.sh $@ ${CONFIG_FILE}"

rmsudo: # unset current user as system administrator
	@echo root password required:
	su -c "bash ${BUILD}/super.sh $@ ${CONFIG_FILE}"
	$(rmvroot)

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
progs: # install set of progs required for this project and in general for power users
	yum install epel-release
	yum install 		\
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
progs:
	apt-get install 	\
		socat		\
		python3.5 python3-pip \
		moreutils	\
		man-db		\
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
		openssh-client openssh-server \
		cscope		\
		exuberant-ctags	\
		colordiff	\
		diffutils	\
		patch		\
		less		\
		util-linux	\
		vim		\
		git		\
		bash-completion	\
		bash		\
		make
	if ${CONFIG_DESKTOP}; then apt-get install \
		gnome-genius	\
		geeqie		\
		vlc		\
		kupfer		\
		audacious	\
		easytag		\
		vim-gtk		\
		firefox		\
		chromium-browser \
		dict dictd dict-gcide \
		xclip		\
		rxvt-unicode	\
	; fi
	if ${CONFIG_MINT}; then apt-get install \
		dconf-cli	\
		mate-panel mate-panel-common \
		mate-applets mate-applets-common \
		mintmenu	\
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
	@egrep '^[a-zA-Z0-9_]*::?( |$$)' ${THIS_MAKEFILE} |	\
		sed '/:[^#]*$$/d; s/:.*# /:/' |			\
		fold -s -w 65 |					\
		sed 's/\(^[^:]*$$\)/ :&/' |			\
		column -s : -t

test: ${CONFIG_FILE} ${ALL_CONFIG_VARS} # dump configuration
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
	@echo "sed commands:"
	@echo " ${SED_COMMANDS}" | tr ';' '\n'

.PHONY: clean build all help test config mrproper
.PHONY: install_luser uninstall_luser upgrade_luser
.PHONY: install_super uninstall_super upgrade_super mksudo rmsudo
.PHONY: install_desktoprefresh uninstall_desktoprefresh upgrade_desktoprefresh
.PHONY: install_desktopinit
