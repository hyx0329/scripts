#!/bin/bash
# meant to be a `wall` alternative
# need: getopt, tty, date

usage="
Usage:
 wall [options] [message]

Write a message to all users.

Options:
 -n, --nobanner          do not print banner
 -h, --help              display this help and exit
"

SHORT=nh
LONG=nobanner,help

if ! PARSED=$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")
then
    echo "$usage"
    exit 2
fi
eval set -- "$PARSED"

while true; do
    case "$1" in
        -n|--nobanner)
            n=y
            shift
            ;;
        -h|--help)
            echo "$usage"
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            exit 3
            ;;
    esac
done

terminals_list=$(ps -ef | awk '{print $6}' | grep -E "(pts/|tty)[0-9]+" | sort -u)

# banner
if [ "$n" ]; then
    pre=""
    post=""
else
    my_tty=$(tty)
    pre="\nBroadcast message from $(whoami)@$(hostname) (${my_tty#/*/}) ($(date +"%a %b %d %H:%M:%S %Y")):\n\n"
    post="\n"
fi

# Hint: if you don't have permission and don't want to use sudo,
# try to write some udev rules and/or create a special group,
# or add your user to desired groups.

# output, here use tee to print on the cli as well
for TTY_TO in $terminals_list; do
  echo -e "$pre$*$post" > "/dev/$TTY_TO"
done

