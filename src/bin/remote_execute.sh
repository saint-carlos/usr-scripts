#!/bin/bash

PROGRAM=$(basename $0)
DESCRIPTION="execute a command on a remote machine"
PARAMS="machine-config-file [command [arg...]]"
OPTIONS="[-hgv]"

usage()
{
	[ $1 -ne 0 ] && exec >&2
    set +x

	cat << EOF
$PROGRAM - $DESCRIPTION
usage:
$PROGRAM $OPTIONS $PARAMS
if no command is given, commands are read from command line.
this script requires that the machine running it is authorized to connect to the target machine without supplying a password.

options:
-h	help: show this help message and exit.
-g	debug: debug the script. the script will be traced.
-v	virtual: don't check the virtual machine; assume it is up.

exit status:
1	bad arguments
otherwise, it is the exit status of the list of commands to be executed.
EOF

    exit $1
}

VM_NEEDS_SUSPEND=false

# @: command to virtual machine
vmware_command()
{
	$IS_VIRTUAL || return 0
	ssh $VMSERVER "vmware-cmd '$VMFILE'" "$@" < /dev/null || die 255 "virtual machine on server $VMSERVER: command $* faild"
}

# VM_NEEDS_SUSPEND: indicates if we need to suspend the current vm.
suspend_vm()
{
	$VM_NEEDS_SUSPEND || return
	VM_NEEDS_SUSPEND=false # if suspends recurses to die(), it will not try to suspend again
	vmware_command suspend hard
}

# exit the script gracefully
# 1: return value to exit with
# 2 (optional): message to display upon exit.
die()
{
    local RC=$1
	[ -n "$2" ] && errcho "${PROGRAM}($$): $2"
	suspend_vm
    exit $RC
}

# return: 0 if the vm is up, 1 if not.
is_vm_up()
{
	$IS_VIRTUAL || return 0
	vmware_command getstate | grep "\= on" > /dev/null
}

# assure the current virtual machine is up.
# VM_NEEDS_SUSPEND: will contain whether (1) or not (0) the current vm needs to be suspended.
assure_vm_up()
{
	$ASSUME_VM_UP && return 0
	$IS_VIRTUAL || return 0
	if is_vm_up; then
		VM_NEEDS_SUSPEND=false
	else
		vmware_command start
		sleep 300 # wait for vm to get operational
		is_vm_up || die 1 "cannot start virtual machine $HOSTNAME ($IP)"
		VM_NEEDS_SUSPEND=true
	fi
}

#####################################################################
# MAIN
#####################################################################

ASSUME_VM_UP=true
while getopts hgv OPTION; do
	case $OPTION in
		h) usage 0 ;;
		g) set -x ;;
		v) ASSUME_VM_UP=false ;;
		\?) usage 1 ;;
	esac
done
shift $((OPTIND - 1))

MACHINE_FILE=$1
shift
[ -n "$MACHINE_FILE" ] || die 255 "no machine file given"
IS_VIRTUAL=false
source "$MACHINE_FILE"
test -n "$VMFILE" && IS_VIRTUAL=true
assure_vm_up
ssh root@${IP} $*
RC=$?
die $RC "execution on remote machine $MACHINE_FILE ($IP) ended with error code $RC"
