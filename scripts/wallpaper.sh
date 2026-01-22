#!/bin/bash
# Wallpaper Picker with swww

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"

# Fallback directories
if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
fi

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper" "No wallpaper directory found" -u critical
    exit 1
fi

# Get list of wallpapers
wallpapers=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) -exec basename {} \; | sort)

if [ -z "$wallpapers" ]; then
    notify-send "Wallpaper" "No wallpapers found" -u critical
    exit 1
fi

# Select with wofi
selected=$(echo "$wallpapers" | wofi --dmenu --prompt "Wallpaper" --cache-file /dev/null)

if [ -z "$selected" ]; then
    exit 0
fi

wallpaper_path="$WALLPAPER_DIR/$selected"

if [ ! -f "$wallpaper_path" ]; then
    notify-send "Wallpaper" "File not found: $selected" -u critical
    exit 1
fi

# Apply with swww
if command -v swww &> /dev/null; then
    swww img "$wallpaper_path" \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 1 \
        --transition-fps 60
    
    notify-send "Wallpaper" "Applied: $selected" -i preferences-desktop-wallpaper
else
    notify-send "Wallpaper" "swww not installed" -u critical
fi
