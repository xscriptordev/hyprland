#!/bin/bash
# Wallpaper Picker - Simple and Reliable

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"

# Fallback directories
if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
fi

if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    WALLPAPER_DIR="$HOME/Pictures"
fi

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper" "No wallpaper directory found" -u critical
    exit 1
fi

# Get list of image files
wallpapers=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; 2>/dev/null | sort)

if [ -z "$wallpapers" ]; then
    notify-send "Wallpaper" "No wallpapers found in $WALLPAPER_DIR" -u critical
    exit 1
fi

# Show picker with wofi
selected=$(echo "$wallpapers" | wofi --dmenu --prompt " Wallpaper" --cache-file /dev/null)

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
    # Check if swww-daemon is running
    if ! pgrep -x "swww-daemon" > /dev/null; then
        swww-daemon &
        sleep 0.5
    fi
    
    swww img "$wallpaper_path" \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 1 \
        --transition-fps 60
    
    notify-send "Wallpaper" "Applied: $selected" -i preferences-desktop-wallpaper
else
    notify-send "Wallpaper" "swww not installed" -u critical
    exit 1
fi
