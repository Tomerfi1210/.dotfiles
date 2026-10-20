#!/bin/bash

source "$(dirname "$0")/../colors.sh"

focused_space="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
drawing=on

case "$1" in
    1|2|3) ;;
    *)
        if [[ "$1" != "$focused_space" ]]; then
            window_count=$(aerospace list-windows --workspace "$1" --count 2>/dev/null)
            if [[ "$window_count" = "0" ]]; then
                drawing=off
            fi
        fi
        ;;
esac

if [[ "$1" = "$focused_space" ]]; then
    sketchybar --set "$NAME" drawing=on background.drawing=on label.color="$BG_SECONDARY" icon.color="$BG_SECONDARY"
else
    sketchybar --set "$NAME" drawing="$drawing" background.drawing=off label.color="$BLUE" icon.color="$BLUE"
fi
