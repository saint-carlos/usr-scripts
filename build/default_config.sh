CONFIG_VROOT=$HOME/vroot
CONFIG_USER_NAME="$USER"
CONFIG_USER_FULL_NAME="$(getent passwd "${USER}" | cut -d: -f5 | cut -d, -f1)"
CONFIG_DOMAIN="$(hostname -d || echo localhost)"
CONFIG_USER_EMAIL="${CONFIG_USER_NAME}@${CONFIG_DOMAIN}"
CONFIG_WORKSPACE=$HOME/workspace
CONFIG_REPO_DIRS=""
CONFIG_USER_PROMPT_COLOR=green # see colorsrc
CONFIG_ROOT_PROMPT_COLOR=yellow # see colorsrc
CONFIG_SYSLOG_FILE=/var/log/messages
CONFIG_PWD_SCREEN_PERCENT=100
CONFIG_PROMPT_USERNAME=true
CONFIG_DESKTOP=false
CONFIG_PD=false
CONFIG_MAIL_SMTP_SERVER="smtp.${CONFIG_DOMAIN}"
CONFIG_MAIL_SMTP_ENCRYPT=plain
CONFIG_MAIL_SMTP_PORT=25
CONFIG_TERMINAL_SCROLLBACK=500000
