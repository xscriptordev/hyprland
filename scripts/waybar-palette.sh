#!/bin/bash

theme_file="$HOME/.config/hypr/theme.conf"

if [ ! -f "$theme_file" ]; then
    echo "#000000"
    exit 0
fi

accent_ref=$(awk -F= '/^\$accent\s*=/{gsub(/\s/ ,"",$2); print $2; exit}' "$theme_file")

if [[ "$accent_ref" =~ ^\$color[0-9]+$ ]]; then
    color_var="$accent_ref"
    hex=$(awk -v v="$color_var" -F= '{gsub(/\s/,"",$1); if($1==v){gsub(/\s/,"",$2); gsub(/rgb\(|\)/,"",$2); print $2; exit}}' "$theme_file")
    if [ -n "$hex" ]; then
        echo "#$hex"
        exit 0
    fi
fi

hex=$(awk -F= '/^\$color1\s*=/{gsub(/\s/,"",$2); gsub(/rgb\(|\)/,"",$2); print $2; exit}' "$theme_file")
if [ -n "$hex" ]; then
    echo "#$hex"
else
    echo "#000000"
fi
