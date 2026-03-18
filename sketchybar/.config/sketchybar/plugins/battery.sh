#!/bin/bash

source "$(dirname "$0")/../colors.sh"

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON="" ;;
  [6-8][0-9]) ICON="" ;;
  [3-5][0-9]) ICON="" ;;
  [1-2][0-9]) ICON="" ;;
  *) ICON=""
esac

if [[ "$CHARGING" != "" ]]; then
  ICON=""
fi

if [ "$PERCENTAGE" -ge 80 ]; then
  COLOR=$GREEN
elif [ "$PERCENTAGE" -ge 50 ]; then
  COLOR=$YELLOW
elif [ "$PERCENTAGE" -ge 20 ]; then
  COLOR=$ORANGE
else
  COLOR=$RED
fi

sketchybar --set "$NAME" icon.color=$COLOR label.color=$FG_DARK icon="$ICON" label="${PERCENTAGE}%"
