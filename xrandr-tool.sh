#!/bin/bash

function get_first_connected_not_primary() {
  xrandr --query | awk -F" " '
  !/^(Screen|\s).*/{ if ($2 == "connected" && $3 != "primary") {printf $1; exit;} else next;}
  '
}

function get_primary() {
  xrandr --query | awk -F" " '
  !/^(Screen|\s).*/{ if ($3 == "primary") {printf $1; exit;} else next;}
  '
}

function get_non_primary() {
  xrandr --query | awk -F" " '
  !/^(Screen|\s).*/{ if ($2 == "connected" && $3 != "primary") {print $1;} else next;}
  '
}

function get_primary_resolution() {
  xrandr -q | awk -F" " '
  BEGIN{resolution=1920x1080}
  !/^(Screen|\s).*/{
    if ($2 == "connected" && $3 == "primary")
      {
        if ($4 ~ /[0-9]+x[0-9ip+]+/)
          match($4, /^[0-9]+x[0-9ip]+/);
          resolution=substr($4,RSTART,RLENGTH);
          exit;
      }
    else next;
  }
  END{printf resolution}
  '
}

function get_all_connected() {
  xrandr --query | awk -F" " '
  !/^(Screen|\s).*/{ if ($2 == "connected") {print $1} else next;}
  '
}

function activate_all() {
  for display in `get_all_connected`; do
    xrandr --output $display --auto
  done
}

function deactivate_all() {
  for display in `get_all_connected`; do
    xrandr --output $display --off
  done
}

function keep_primary() {
  for display in `get_non_primary`; do
    xrandr --output $display --off
  done
  xrandr --output $primary --auto
}

function swap_primary() {
  xrandr --output $secondary --primary
}

function extend_to_left() {
  xrandr --output $secondary --left-of $primary --auto
}

function extend_to_right() {
  xrandr --output $secondary --right-of $primary --auto
}

function mirror_screen() {
  xrandr --output $primary --auto
  resolution=`get_primary_resolution`
  for display in `get_non_primary`; do
    xrandr --output $display --mode $resolution --same-as $primary
  done
}

function print_usage() {
  cat << EOF
Usage: $0 <option>

options:
  el|extend-left        set secondary screen left of the primary
  er|extend-right       set secondary screen right of the primary
  m |mirror             make secondary mirror the primary
  aa|activate-all       activate all connected screen
  po|primary-only       only use primary screen
  sw|switch             change(switch) the primary screen
  so|switch-output      change(switch) the primary screen and keep only primary
EOF
}

function check_secondary_wrapper() {
  if [ -z $secondary ]; then
    echo "not enough display"
    return 1
  fi

  return 0
}

if [ $# -ne 1 ] ; then
  print_usage
  exit 0
fi

primary=`get_primary`
secondary=`get_first_connected_not_primary`

option=$1

case $option in
  el|extend-left)
    check_secondary_wrapper && extend_to_left
    ;; 
  er|extend-right)
    check_secondary_wrapper && extend_to_right
    ;;
  m|mirror)
    check_secondary_wrapper && mirror_screen
    ;;
  aa|activate-all)
    check_secondary_wrapper && activate_all
    ;;
  po|primary-only)
    check_secondary_wrapper && keep_primary
    ;;
  sw|switch)
    check_secondary_wrapper && swap_primary
    ;;
  so|switch-output)
    check_secondary_wrapper && swap_primary
    primary=`get_primary`
    secondary=`get_first_connected_not_primary`
    keep_primary
    ;;
  *)
    print_usage
    ;;
esac
