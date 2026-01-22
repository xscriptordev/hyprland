#!/bin/bash

mode="${1:-drun}"

if command -v rofi >/dev/null 2>&1; then
    rofi -show "$mode" -show-icons -theme "$HOME/.config/rofi/launcher.rasi"
    exit 0
fi

if command -v wofi >/dev/null 2>&1; then
    if [ "$mode" = "run" ]; then
        wofi --show run
    else
        wofi --show drun
    fi
    exit 0
fi

exit 1

