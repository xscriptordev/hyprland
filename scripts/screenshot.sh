#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Screenshot Script                                                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

FILENAME="screenshot_$(date +%Y%m%d_%H%M%S).png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"

case "$1" in
    full)
        grim "$FILEPATH"
        ;;
    area)
        grim -g "$(slurp)" "$FILEPATH"
        ;;
    window)
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$FILEPATH"
        ;;
    *)
        echo "Usage: $0 {full|area|window}"
        exit 1
        ;;
esac

if [ -f "$FILEPATH" ]; then
    wl-copy < "$FILEPATH"
    notify-send "Screenshot" "Saved to $FILENAME" -i "$FILEPATH"
fi
