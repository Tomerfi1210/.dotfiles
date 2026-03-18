#!/bin/bash

source "$(dirname "$0")/../colors.sh"

if [[ -z "$FOCUSED_WORKSPACE" ]]; then
    focused_space=$(aerospace list-workspaces --focused)
    focused_count=$(aerospace list-windows --workspace "$focused_space" --count 2>/dev/null)

    if ! [[ "$focused_count" =~ ^[0-9]+$ ]]; then
        focused_count=0
    fi

    sketchybar --set space."$focused_space" background.drawing=on label.color=$BG_SECONDARY label="$focused_space [$focused_count]"
elif [[ "$1" = "$FOCUSED_WORKSPACE" ]]; then
    focused_count=$(aerospace list-windows --workspace "$FOCUSED_WORKSPACE" --count 2>/dev/null)

    if ! [[ "$focused_count" =~ ^[0-9]+$ ]]; then
        focused_count=0
    fi

    sketchybar --set "$NAME" background.drawing=on label.color=$BG_SECONDARY label="$1 [$focused_count]"
else
    workspace_label="${NAME#space.}"
    sketchybar --set "$NAME" background.drawing=off label.color=$BLUE label="$workspace_label"
fi
