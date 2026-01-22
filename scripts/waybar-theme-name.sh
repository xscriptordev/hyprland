#!/bin/bash

theme_file="$HOME/.config/hypr/theme.conf"

if [ ! -f "$theme_file" ]; then
    echo "X"
    exit 0
fi

line=$(grep -m1 -E '^#\s*(Theme:|║\s*THEME:)' "$theme_file" 2>/dev/null)
if [ -z "$line" ]; then
    echo "X"
    exit 0
fi

name=$(echo "$line" | sed -E 's/^#\s*(Theme:|║\s*THEME:)\s*//')
name=$(echo "$name" | sed -E 's/\s*\(.*\)\s*$//')
name=$(echo "$name" | awk '{$1=$1};1')

if [ -z "$name" ]; then
    echo "X"
else
    echo "$name"
fi

