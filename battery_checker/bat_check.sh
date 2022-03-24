#!/bin/bash
# simple battery checker
#
# Self description:

#   I'll calculate average battery level
#   and report through notify-send when
#   no external power source is attached.
#
#   I'll only send alerts when related
#   levels are set.
#

LOW_LEVEL=${BAT_LOW_LEVEL:-15}
CRITICAL_LEVEL=${BAT_CRITICAL_LEVEL:-7}

POWER_DIR="/sys/class/power_supply"
BATTERIES=$(ls "$POWER_DIR"|grep BAT)
BATTERIES=($(echo "$BATTERIES"))
POWER="AC"
POWER_FILE=$POWER_DIR/$POWER/online

function check_power_source() {
  if [ -f "$POWER_FILE" ]; then
    power_status=$(cat $POWER_FILE)
    if [ $power_status -eq 1 ]; then
      # power connected
      return 0
    fi
  fi
  # power disconnected
  return 1
}

function bat_check() {
  bat_count=${#BATTERIES[@]}
  if [ 0 -ne $bat_count ]; then
    # has battery
    bat_level=0
    for bat in $(echo ${BATTERIES[@]}); do
      energy_current=$(cat $POWER_DIR/$bat/energy_now)
      energy_maxium=$(cat $POWER_DIR/$bat/energy_full)
      energy_level=$((energy_current*100/energy_maxium))
      bat_level=$((bat_level+energy_level))
    done
    bat_level=$((bat_level/bat_count))
    echo $bat_level
    return 0
  else
    # no battery
    return 1
  fi
}

function main() {
  bat_level=`bat_check`
  if [ 0 -ne $? ]; then
    # no battery, skip any following action
    return 0
  fi
  
  if `check_power_source`; then
    logger "Battery monitor report: Powered $bat_level%"
  else
    if [ $CRITICAL_LEVEL -ge $bat_level ]; then
      notify-send -u critical -i battery-empty "Battery Critical: $bat_level%"
    elif [ $LOW_LEVEL -ge $bat_level ]; then
      notify-send -t 3000 -i battery-low "Battery Low: $bat_level%"
    fi
    logger "Battery monitor report: Unpowered $bat_level%"
  fi
}

#set -x
main

