#!/bin/bash

if pgrep -x wlogout >/dev/null 2>&1; then
    pkill -x wlogout
    exit 0
fi

wlogout -b 6 -c 0 -r 0 -m 0 --layout "$HOME/.config/wlogout/layout_1" --css "$HOME/.config/wlogout/style_1.css" --protocol layer-shell

