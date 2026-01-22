#!/bin/bash
# Wallpaper Picker with Thumbnails using Wofi

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
THUMB_SIZE="150x100"

# Create cache dir
mkdir -p "$CACHE_DIR"

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

# Generate entries with thumbnails
entries=""
shopt -s nullglob nocaseglob
for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp}; do
    [ -f "$img" ] || continue
    
    filename=$(basename "$img")
    name="${filename%.*}"
    thumb="$CACHE_DIR/${filename}.png"
    
    # Generate thumbnail if missing or outdated
    if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
        if command -v magick &> /dev/null; then
            magick "$img" -resize "$THUMB_SIZE^" -gravity center -extent "$THUMB_SIZE" "$thumb" 2>/dev/null
        elif command -v convert &> /dev/null; then
            convert "$img" -resize "$THUMB_SIZE^" -gravity center -extent "$THUMB_SIZE" "$thumb" 2>/dev/null
        fi
    fi
    
    # Format: img:<path>:text:<name>
    if [ -f "$thumb" ]; then
        entries+="img:${thumb}:text:${name}\n"
    else
        entries+="${filename}\n"
    fi
done
shopt -u nocaseglob nullglob

if [ -z "$entries" ]; then
    notify-send "Wallpaper" "No wallpapers found in $WALLPAPER_DIR" -u critical
    exit 1
fi

# Show wofi picker with images
selected=$(printf "%b" "$entries" | wofi --dmenu \
    --prompt " Wallpaper" \
    --cache-file /dev/null \
    --allow-images \
    --define image_size=150 \
    --columns 4 \
    --width 1000 \
    --height 600 \
    --style "$HOME/.config/wofi/wallpaper.css")

if [ -z "$selected" ]; then
    exit 0
fi

# Extract the name from selection
if [[ "$selected" == img:*:text:* ]]; then
    name="${selected#img:}"
    name="${name#*:text:}"
else
    name="$(basename "$selected")"
    name="${name%.*}"
fi

# Find the actual file
wallpaper=""
for ext in jpg jpeg png webp JPG JPEG PNG WEBP; do
    if [ -f "$WALLPAPER_DIR/$name.$ext" ]; then
        wallpaper="$WALLPAPER_DIR/$name.$ext"
        break
    fi
done

# Fallback: try to match by name
if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
    for img in "$WALLPAPER_DIR"/*; do
        [ -f "$img" ] || continue
        imgname=$(basename "${img%.*}")
        if [ "$imgname" = "$name" ]; then
            wallpaper="$img"
            break
        fi
    done
fi

if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
    notify-send "Wallpaper" "Could not find: $name" -u critical
    exit 1
fi

# Ensure swww-daemon is running
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 0.5
fi

# Randomize transition
# Possible types: simple, fade, left, right, top, bottom, wipe, wave, grow, center, any, outer
types=("fade" "left" "right" "top" "bottom" "wipe" "wave" "grow" "center" "outer")
# Possible positions: center, top, left, right, bottom, top-left, top-right, bottom-left, bottom-right
positions=("center" "top" "left" "right" "bottom" "top-left" "top-right" "bottom-left" "bottom-right")

# Get random index
rand_type=${types[$RANDOM % ${#types[@]}]}
rand_pos=${positions[$RANDOM % ${#positions[@]}]}

# Apply wallpaper with random transition
swww img "$wallpaper" \
    --transition-type "$rand_type" \
    --transition-pos "$rand_pos" \
    --transition-duration 2 \
    --transition-fps 60

notify-send "Wallpaper" "Applied: $(basename "$wallpaper")" -i preferences-desktop-wallpaper
