#!/usr/bin/env bash

## Author  : hyx0329
## Mail    : hyx0329@163.com
## Github  : @hyx0329
## Requirements: autorandr, xdisplay-tool.sh
## Description: use rofi to issue commands to switch display outputs

basedir="$HOME/.config/rofi/xdisplay"
xdisplay_tool="$basedir/xdisplay-tool.sh"
rofi_command="rofi"


# Message
msg() {
	rofi -e "$@"
}

# Options
primary_only='Primary only'
secondary_only='Secondary only'
extend_left='Extend to left'
extend_right='Extend to right'
swap_primary='Swap primary and secondary and keep only primary'
mirror_outputs='Mirror primary output'
clone_largest='Clone largest'

if test -x "$(which autorandr)"; then
    autorandr_profiles=$(autorandr --list)
else
    autorandr_profiles=''
fi
autorandr_profiles_list=($autorandr_profiles)

# do the choice
chosen="$(cat << EOF | $rofi_command -p "Change Display Output" -dmenu -i -selected-row 5
$primary_only
$secondary_only
$extend_left
$extend_right
$mirror_outputs
$clone_largest
$autorandr_profiles
EOF
)"

if test -z "$chosen"; then
    exit 0
fi

case $chosen in
    $primary_only)
        $xdisplay_tool po
    ;;
    $secondary_only)
        $xdisplay_tool so
    ;;
    $extend_left)
        $xdisplay_tool el
    ;;
    $extend_right)
        $xdisplay_tool er
    ;;
    $swap_primary)
        $xdisplay_tool sw
    ;;
    $mirror_outputs)
        $xdisplay_tool m
    ;;
    $clone_largest)
        autorandr -c clone-largest
    ;;
    *)
        # TODO: add validation
        autorandr -c $chosen
    ;;
esac

