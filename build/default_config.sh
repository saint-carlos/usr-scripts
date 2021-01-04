# format: these are just bash assignment
# you can run advanced assignment constructs
# or shell commands to generate values for variables
# better not run commands with side effects!
# replace relative variables like $HOME and $USER, otherwise it doesn't work with sudo

# where everything is installed
CONFIG_VROOT="$HOME/vroot"

# system user name
CONFIG_USER_NAME="$USER"
# name for humans to read
CONFIG_USER_FULL_NAME="$(getent passwd "${CONFIG_USER_NAME}" | cut -d: -f5 | cut -d, -f1)"
# email domain
CONFIG_DOMAIN="$([ -n "$(dnsdomainname)" ] && dnsdomainname || hostname -f)"
# user's email
CONFIG_USER_EMAIL="${CONFIG_USER_NAME}@${CONFIG_DOMAIN}"

# whether or not we care about security on this machine
CONFIG_SECURE=true
# groups to which to add the user (for mksudo); see /etc/group
# user will be added to group only if group exists
CONFIG_NONDEFAULT_GROUPS="docker:vboxusers:libvirtd"
# disable unencrypted caches (files or directories); colon separated
# this is for privacy, since those caches are accessible and aren't purged
# this may cause some applications (e.g. mplayer) to crash or malfunction
CONFIG_DISABLE_CACHE_FILES=""
CONFIG_DISABLE_CACHE_FILES+=":.local/share/recently-used.xbel"
CONFIG_DISABLE_CACHE_FILES+=":.config/geeqie/history"
CONFIG_DISABLE_CACHE_FILES+=":.config/gnome-mplayer/gnome-mplayer.db"
CONFIG_DISABLE_CACHE_FILES+=":.local/share/gthumb/catalogs/Command Line.catalog"
CONFIG_DISABLE_CACHE_FILES+=":.local/share/beatbox/beatbox.db"
CONFIG_DISABLE_CACHE_FILES+=":.kinorc"
CONFIG_DISABLE_CACHE_FILES+=":.audacity-data/audacity.cfg"
CONFIG_DISABLE_CACHE_DIRS=""
CONFIG_DISABLE_CACHE_DIRS+=":.thumbnails"
CONFIG_DISABLE_CACHE_DIRS+=":.kde/share/apps/RecentDocuments"
CONFIG_DISABLE_CACHE_DIRS+=":.icedtea/cache"

# main working directory, for the 'j' command
CONFIG_WORKSPACE="$HOME/workspace"
# additional working directories, for the 'j' command
CONFIG_REPO_DIRS=""

# prompt color; pick from colorsrc
CONFIG_PROMPT_COLOR=$([ $UID -eq 0 ] && echo yellow || echo green)
# spell out username in prompt?
CONFIG_PROMPT_USERNAME=false
# prefix prompt with next command's history number
CONFIG_PROMPT_HISTORY_NUM=true
# if prompt-length/terminal-width > this-percentage, abbreviate pwd in prompt
CONFIG_PWD_SCREEN_PERCENT=30

# number of lines in terminal scrollback buffer
CONFIG_TERMINAL_SCROLLBACK=500000

# mainly to route git-send-email(1) via the company's email server
# empty means no routing
CONFIG_MAIL_SMTP_SERVER="smtp.${CONFIG_DOMAIN}"
CONFIG_MAIL_SMTP_PORT=25
CONFIG_MAIL_SMTP_ENCRYPT="plain"

# mostly GUI stuff
CONFIG_DESKTOP=false
# number of workspaces
CONFIG_NUM_WORKSPACES=1
# for clock applet: list of locations
# colon separated, prefix one with '~' for current location
# example: "Berlin:~San Francisco:London"
CONFIG_CITIES=""
# colon separated, first is default; pick from ISO 639-1
CONFIG_LANGUAGES="us"
# directory containing stuff displayed on the desktop
CONFIG_DESKTOP_DIR=".desktop"
# personal temporary directory, also used for downloads
CONFIG_HOME_TMP_DIR="tmp"
# theme
CONFIG_WINDOW_MANAGER_THEME="ClearlooksRe"
CONFIG_GTK_THEME="Mint-Y-Dark-Teal"
CONFIG_ICON_THEME="menta"
CONFIG_TITLEBAR_FONT="Sans Bold 12"
# enable or disable specific startup applications
# colon separated; pick from /etc/xdg/autostart and /usr/share/applications
# unlisted applications will be left untouched
CONFIG_AUTOSTART_ENABLE=""
CONFIG_AUTOSTART_ENABLE+=":kupfer"
CONFIG_AUTOSTART_ENABLE+=":mate-screensaver"
CONFIG_AUTOSTART_ENABLE+=":mate-volume-control-applet"
CONFIG_AUTOSTART_ENABLE+=":nm-applet"
CONFIG_AUTOSTART_ENABLE+=":pulseaudio"
CONFIG_AUTOSTART_DISABLE=""
CONFIG_AUTOSTART_DISABLE+=":mintupdate"
CONFIG_AUTOSTART_DISABLE+=":mintupload"
CONFIG_AUTOSTART_DISABLE+=":mintwelcome"
CONFIG_AUTOSTART_DISABLE+=":onboard-autostart"
CONFIG_AUTOSTART_DISABLE+=":user-dirs-update-gtk"
CONFIG_AUTOSTART_DISABLE+=":mint-ctrl-alt-backspace"
CONFIG_AUTOSTART_DISABLE+=":vino-server"
CONFIG_AUTOSTART_DISABLE+=":mate-at-session"
