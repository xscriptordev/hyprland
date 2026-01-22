#!/bin/bash

if pgrep -x wlogout >/dev/null 2>&1; then
    pkill -x wlogout
    exit 0
fi

wlogout -b 5 -c 22 -r 22 -m 120 --layout "$HOME/.config/wlogout/layout_1" --css "$HOME/.config/wlogout/style_1.css" --protocol layer-shell
