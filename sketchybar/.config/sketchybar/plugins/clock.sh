#!/bin/bash

source "$(dirname "$0")/../colors.sh"

sketchybar --set "$NAME" icon.color=$CYAN label.color=$FG_DARK label="$(date '+%Y-%m-%d %H:%M')"
