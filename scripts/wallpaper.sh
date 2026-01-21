#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Wallpaper Script                                                          ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
DEFAULT_WALLPAPER="$WALLPAPER_DIR/default.jpg"

set_wallpaper() {
    local file="$1"
    swww img "$file" \
        --transition-type grow \
        --transition-pos center \
        --transition-fps 60 \
        --transition-duration 2
}

case "$1" in
    set)
        if [ -n "$2" ] && [ -f "$2" ]; then
            set_wallpaper "$2"
        else
            echo "Usage: $0 set <path_to_image>"
            exit 1
        fi
        ;;
    random)
        if [ -d "$WALLPAPER_DIR" ]; then
            random_file=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)
            if [ -n "$random_file" ]; then
                set_wallpaper "$random_file"
                notify-send "Wallpaper" "Changed to: $(basename "$random_file")" -i preferences-desktop-wallpaper
            fi
        else
            echo "Wallpaper directory not found: $WALLPAPER_DIR"
            exit 1
        fi
        ;;
    select)
        selected=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) -printf "%f\n" | wofi --dmenu --prompt "Select Wallpaper" --cache-file /dev/null)
        if [ -n "$selected" ]; then
            set_wallpaper "$WALLPAPER_DIR/$selected"
            notify-send "Wallpaper" "Changed to: $selected" -i preferences-desktop-wallpaper
        fi
        ;;
    *)
        # Default: open selector
        selected=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) -printf "%f\n" 2>/dev/null | wofi --dmenu --prompt "Select Wallpaper" --cache-file /dev/null)
        if [ -n "$selected" ]; then
            set_wallpaper "$WALLPAPER_DIR/$selected"
            notify-send "Wallpaper" "Changed to: $selected" -i preferences-desktop-wallpaper
        fi
        ;;
esac
