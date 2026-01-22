#!/bin/bash
# Wallpaper Picker with Thumbnails using Wofi

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
THUMB_SIZE="150x100"
THUMB_SQRE_SIZE="256x256"

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

use_rofi=0
if command -v rofi >/dev/null 2>&1; then
    use_rofi=1
fi

entries=""
shopt -s nullglob nocaseglob
for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp}; do
    [ -f "$img" ] || continue
    
    filename=$(basename "$img")
    name="${filename%.*}"
    thumb="$CACHE_DIR/${filename}.png"
    thumb_sqre="$CACHE_DIR/${filename}.sqre.png"
    
    if [ "$use_rofi" -eq 1 ]; then
        if [ ! -f "$thumb_sqre" ] || [ "$img" -nt "$thumb_sqre" ]; then
            if command -v magick &> /dev/null; then
                magick "$img" -resize "$THUMB_SQRE_SIZE^" -gravity center -extent "$THUMB_SQRE_SIZE" "$thumb_sqre" 2>/dev/null
            elif command -v convert &> /dev/null; then
                convert "$img" -resize "$THUMB_SQRE_SIZE^" -gravity center -extent "$THUMB_SQRE_SIZE" "$thumb_sqre" 2>/dev/null
            fi
        fi
        if [ -f "$thumb_sqre" ]; then
            entries+="${filename}:::${img}:::${thumb_sqre}\0icon\x1f${thumb_sqre}\n"
        else
            entries+="${filename}:::${img}:::${img}\n"
        fi
    else
        if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
            if command -v magick &> /dev/null; then
                magick "$img" -resize "$THUMB_SIZE^" -gravity center -extent "$THUMB_SIZE" "$thumb" 2>/dev/null
            elif command -v convert &> /dev/null; then
                convert "$img" -resize "$THUMB_SIZE^" -gravity center -extent "$THUMB_SIZE" "$thumb" 2>/dev/null
            fi
        fi
        if [ -f "$thumb" ]; then
            entries+="img:${thumb}:text:${name}\n"
        else
            entries+="${filename}\n"
        fi
    fi
done
shopt -u nocaseglob nullglob

if [ -z "$entries" ]; then
    notify-send "Wallpaper" "No wallpapers found in $WALLPAPER_DIR" -u critical
    exit 1
fi

if [ "$use_rofi" -eq 1 ]; then
    mon_x_res=1920
    mon_scale=100
    if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        mon_x_res=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .width' 2>/dev/null)
        mon_scale=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .scale' 2>/dev/null | sed 's/\.//')
        mon_x_res=${mon_x_res:-1920}
        mon_scale=${mon_scale:-100}
    fi
    mon_x_res=$((mon_x_res * 100 / mon_scale))
    columns=$((mon_x_res / 360))
    [ "$columns" -lt 3 ] && columns=3
    [ "$columns" -gt 7 ] && columns=7

    selected=$(printf "%b" "$entries" | rofi -dmenu \
        -p "Wallpaper" \
        -display-column-separator ":::" \
        -display-columns 1 \
        -show-icons \
        -theme "$HOME/.config/rofi/selector.rasi" \
        -theme-str "listview { columns: ${columns}; }")
else
    selected=$(printf "%b" "$entries" | wofi --dmenu \
        --prompt " Wallpaper" \
        --cache-file /dev/null \
        --allow-images \
        --define image_size=150 \
        --columns 4 \
        --width 1000 \
        --height 600 \
        --style "$HOME/.config/wofi/wallpaper.css")
fi

if [ -z "$selected" ]; then
    exit 0
fi

if [ "$use_rofi" -eq 1 ]; then
    wallpaper=$(awk -F ':::' '{print $2}' <<<"$selected")
else
    if [[ "$selected" == img:*:text:* ]]; then
        name="${selected#img:}"
        name="${name#*:text:}"
    else
        name="$(basename "$selected")"
        name="${name%.*}"
    fi

    wallpaper=""
    for ext in jpg jpeg png webp JPG JPEG PNG WEBP; do
        if [ -f "$WALLPAPER_DIR/$name.$ext" ]; then
            wallpaper="$WALLPAPER_DIR/$name.$ext"
            break
        fi
    done

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
    --transition-fps 120

notify-send "Wallpaper" "Applied: $(basename "$wallpaper")" -i preferences-desktop-wallpaper
