#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

# if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
#   sketchybar --set $NAME background.drawing=on
# else
#   sketchybar --set $NAME background.drawing=off
# fi
#

if [[ -z "$FOCUSED_WORKSPACE" ]]; then
  focused_space=$(aerospace list-workspaces --focused)
  sketchybar --set space.$focused_space background.drawing=on label.color=0xff000000 label="$focused_space"
elif [[ "$1" = "$FOCUSED_WORKSPACE" ]]; then
  sketchybar --set $NAME background.drawing=on label.color=0xff000000 label="$1"
else
  sketchybar --set $NAME background.drawing=off label.color=0x44ffffff label="$(echo $NAME | grep -Eo '[0-9]{1,4}')"
fi
