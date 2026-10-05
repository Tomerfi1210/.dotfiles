#!/bin/bash

source "$(dirname "$0")/../colors.sh"

if [[ -z "$FOCUSED_WORKSPACE" ]]; then
    focused_space=$(aerospace list-workspaces --focused)
    sketchybar --set space."$focused_space" background.drawing=on label.color=$BG_SECONDARY
elif [[ "$1" = "$FOCUSED_WORKSPACE" ]]; then
    sketchybar --set "$NAME" background.drawing=on label.color=$BG_SECONDARY
else
    sketchybar --set "$NAME" background.drawing=off label.color=$BLUE
fi
