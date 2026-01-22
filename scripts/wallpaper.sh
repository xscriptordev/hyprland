#!/bin/bash
# Wallpaper Picker with Thumbnails

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
THUMB_SIZE="200x120"

# Create cache dir
mkdir -p "$CACHE_DIR"

# Fallback
if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
fi

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper" "No wallpaper directory found" -u critical
    exit 1
fi

# Generate thumbnails and create list
entries=""
for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp} 2>/dev/null; do
    [ -f "$img" ] || continue
    
    filename=$(basename "$img")
    name="${filename%.*}"
    thumb="$CACHE_DIR/${filename}.png"
    
    # Generate thumbnail if needed
    if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
        convert "$img" -resize "$THUMB_SIZE^" -gravity center -extent "$THUMB_SIZE" \
            -background none \( +clone -alpha extract -draw 'fill black polygon 0,0 0,15 15,0 fill white circle 15,15 15,0' \
            \( +clone -flip \) -compose Multiply -composite \
            \( +clone -flop \) -compose Multiply -composite \) \
            -alpha off -compose CopyOpacity -composite "$thumb" 2>/dev/null || \
        convert "$img" -resize "$THUMB_SIZE^" -gravity center -extent "$THUMB_SIZE" "$thumb" 2>/dev/null
    fi
    
    if [ -f "$thumb" ]; then
        entries+="img:$thumb:text:$name\n"
    else
        entries+="$name\n"
    fi
done

if [ -z "$entries" ]; then
    notify-send "Wallpaper" "No wallpapers found" -u critical
    exit 1
fi

# Show picker
selected=$(echo -e "$entries" | wofi --show dmenu \
    --prompt "Wallpaper" \
    --cache-file /dev/null \
    --allow-images \
    --columns 3 \
    --width 800 \
    --height 500)

if [ -z "$selected" ]; then
    exit 0
fi

# Extract name (remove img: prefix if present)
name=$(echo "$selected" | sed 's/^img:[^:]*:text://' | sed 's/^text://')

# Find the actual file
wallpaper=""
for ext in jpg jpeg png webp; do
    if [ -f "$WALLPAPER_DIR/$name.$ext" ]; then
        wallpaper="$WALLPAPER_DIR/$name.$ext"
        break
    fi
done

if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
    # Try exact match with extension
    for img in "$WALLPAPER_DIR"/*; do
        if [[ "$(basename "${img%.*}")" == "$name" ]]; then
            wallpaper="$img"
            break
        fi
    done
fi

if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
    notify-send "Wallpaper" "Could not find: $name" -u critical
    exit 1
fi

# Apply with swww
if command -v swww &> /dev/null; then
    swww img "$wallpaper" \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 1 \
        --transition-fps 60
    
    notify-send "Wallpaper" "Applied: $(basename "$wallpaper")" -i preferences-desktop-wallpaper
else
    notify-send "Wallpaper" "swww not installed" -u critical
fi
