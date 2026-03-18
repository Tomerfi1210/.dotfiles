#!/bin/bash

source "$(dirname "$0")/../colors.sh"

INFO="$(en="$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $NF}')"; ipconfig getsummary "$en" | grep -Fxq "  Active : FALSE" || networksetup -listpreferredwirelessnetworks "$en" | sed -n '2s/^\t//p')"
IP="$(ipconfig getifaddr en0)"

ICON="$([ -n "$IP" ] && echo "" || echo "󱛅")"
LABEL="$([ -n "$IP" ] && echo "$INFO" || echo "Disconnected")"

if [ -n "$IP" ]; then
  COLOR=$GREEN
else
  COLOR=$RED
fi

sketchybar --set "$NAME" icon.color=$COLOR label.color=$FG_DARK icon="$ICON" label="$LABEL"
