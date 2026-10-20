#!/bin/bash

sketchybar --add event aerospace_workspace_change

WORKSPACES=$(aerospace list-workspaces --all)
AGGREGATED=$(echo "$WORKSPACES" | awk '{print "space." $1}' | paste -sd ' ' -)

for sid in $WORKSPACES; do
    case "$sid" in
        1) workspace_label="1 Ghostty"; workspace_icon="" ;;
        2) workspace_label="2 Chrome"; workspace_icon="" ;;
        3) workspace_label="3 Slack"; workspace_icon="" ;;
        4) workspace_label="4 OpenVPN"; workspace_icon="" ;;
        *) workspace_label="$sid"; workspace_icon="" ;;
    esac

    sketchybar --add item space."$sid" left \
        --subscribe space."$sid" aerospace_workspace_change front_app_switched \
        --set space."$sid" \
        background.color="$BLUE" \
        background.corner_radius=20 \
        background.height=20 \
        background.drawing=off \
        background.padding_left=3 \
        background.padding_right=3 \
        icon="$workspace_icon" \
        icon.color="$BLUE" \
        label="$workspace_label" \
        label.color="$FG_DARK" \
        update_freq=5 \
        updates=on \
        click_script="aerospace workspace $sid" \
        script="$PLUGIN_DIR/aerospace.sh $sid"
done

sketchybar --add bracket left_pill_bg apple_logo $AGGREGATED \
           --set left_pill_bg background.color="$BG_SECONDARY" \
                              background.corner_radius=20 \
                              background.height=36 \
                              background.padding_left=3 \
                              background.padding_right=3 \
                              background.blur_radius=20
