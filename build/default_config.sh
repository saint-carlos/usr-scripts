# format: these are just bash assignment
# you can run advanced assignment constructs
# or shell commands to generate values for variables
# better not run commands with side effects!

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

# main working directory, for the 'j' command
CONFIG_WORKSPACE="$HOME/workspace"
# additional working directories, for the 'j' command
CONFIG_REPO_DIRS=""

# prompt color; pick from colorsrc
CONFIG_PROMPT_COLOR=$([ $UID -eq 0 ] && echo yellow || echo green)
# spell out username in prompt?
CONFIG_PROMPT_USERNAME=true
# if prompt-length/terminal-width > this-percentage, abbreviate pwd in prompt
CONFIG_PWD_SCREEN_PERCENT=100

# number of lines in terminal scrollback buffer
CONFIG_TERMINAL_SCROLLBACK=500000

# mainly to route git-send-email(1) via the company's email server
# empty means no routing
CONFIG_MAIL_SMTP_SERVER="smtp.${CONFIG_DOMAIN}"
CONFIG_MAIL_SMTP_PORT=25
CONFIG_MAIL_SMTP_ENCRYPT="plain"

# mostly GUI stuff
CONFIG_DESKTOP=false
# directory containing stuff displayed on the desktop
CONFIG_DESKTOP_DIR=".desktop"
# personal temporary directory, also used for downloads
CONFIG_HOME_TMP_DIR="tmp"
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
