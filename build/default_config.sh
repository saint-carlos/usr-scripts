VROOT_PLACEHOLDER=~/vroot
USER_FULL_NAME_PLACEHOLDER="$(getent passwd "${USER}" | cut -d: -f5 | cut -d, -f1)"
USERMAIL_PLACEHOLDER="${USER}@$(hostname -d)"
WORKSPACE_PLACEHOLDER=~/workspace
REPO_ROOT_LIST_PLACEHOLDER=""
USER_PROMPT_COLOR_PLACEHOLDER=GREEN # see colorsrc
ROOT_PROMPT_COLOR_PLACEHOLDER=YELLOW # see colorsrc
MESSAGES_PLACEHOLDER=/var/log/messages
PWD_PERCENTAGE_PLACEHOLDER=25
