#!/bin/sh

check_threshold() {
  echo "$1 >= $2" | bc -l
}

if [ "$(check_threshold $CPU_USAGE 0.85)" -eq 1 ]; then
  COLOR="0xffff5555"
elif [ "$(check_threshold $CPU_USAGE 0.6)" -eq 1 ]; then
  COLOR="0xffffb86c"
elif [ "$(check_threshold $CPU_USAGE 0.2)" -eq 1 ]; then
  COLOR="0xfff1fa8c"
else
  COLOR="0xff50fa7b"
fi

sketchybar --push "$NAME" $CPU_USAGE \
  --set $NAME icon.color=$COLOR
