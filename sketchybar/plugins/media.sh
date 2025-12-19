#!/bin/sh

# sketchybar --set "$NAME" label="$PLAYING"
status=$(media-control get)

if [[ $status != "null" ]]; then
  playing=$(jq -r 'if .playing != null then .playing else empty end' <<<$status)
  sketchybar --set "$NAME" label="$(jq -r 'if .title then .title else empty end' <<<$status)"
  if [[ "$playing" == "true" ]]; then
    sketchybar --set $NAME icon="" label.color=0xff50fa7b icon.color=0xff50fa7b scroll_texts=on
  else
    sketchybar --set $NAME icon="" label.color=0xffffb86c icon.color=0xffffb86c scroll_texts=off
  fi
else 
  sketchybar --set "$NAME" label="" icon=""
fi 
