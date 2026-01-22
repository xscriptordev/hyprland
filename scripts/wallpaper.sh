#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Wallpaper Picker with Image Preview                                       ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-picker"

# Create cache directory
mkdir -p "$CACHE_DIR"

# Fallback directories
if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
fi

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Picker" "No wallpaper directory found!" -u critical
    exit 1
fi

# Generate thumbnails and list
generate_list() {
    for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp} 2>/dev/null; do
        [ -f "$img" ] || continue
        
        filename=$(basename "$img")
        thumb="$CACHE_DIR/${filename}.thumb.png"
        
        # Generate thumbnail if not exists
        if [ ! -f "$thumb" ]; then
            convert "$img" -resize 100x60^ -gravity center -extent 100x60 "$thumb" 2>/dev/null
        fi
        
        # Output: img:thumbnail	display_name
        if [ -f "$thumb" ]; then
            echo "img:$thumb	$filename"
        else
            echo "$filename"
        fi
    done
}

# Main
wallpapers=$(generate_list)

if [ -z "$wallpapers" ]; then
    notify-send "Wallpaper Picker" "No wallpapers found!" -u critical
    exit 1
fi

# Use wofi with images
selected=$(echo "$wallpapers" | wofi --dmenu --prompt "Select Wallpaper" --cache-file /dev/null --allow-images)

if [ -z "$selected" ]; then
    exit 0
fi

# Extract filename (after tab)
filename=$(echo "$selected" | awk -F'\t' '{print $2}')
if [ -z "$filename" ]; then
    filename="$selected"
fi

wallpaper_path="$WALLPAPER_DIR/$filename"

if [ ! -f "$wallpaper_path" ]; then
    notify-send "Wallpaper Picker" "File not found: $filename" -u critical
    exit 1
fi

# Apply wallpaper with swww
if command -v swww &> /dev/null; then
    swww img "$wallpaper_path" \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 1 \
        --transition-fps 60
    
    notify-send "Wallpaper" "Applied: $filename" -i preferences-desktop-wallpaper
else
    notify-send "Wallpaper Picker" "swww not installed!" -u critical
fi
