#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Theme Switcher Script                                                     ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

THEMES_DIR="$HOME/.config/hypr/themes"
CURRENT_THEME="$HOME/.config/hypr/theme.conf"
CONFIG_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
SCRIPT_THEMES_DIR="$CONFIG_DIR/themes"

# Check if themes are in config location
if [ -d "$THEMES_DIR" ]; then
    SOURCE_DIR="$THEMES_DIR"
elif [ -d "$SCRIPT_THEMES_DIR" ]; then
    SOURCE_DIR="$SCRIPT_THEMES_DIR"
else
    notify-send "Theme Switcher" "No themes directory found!" -u critical
    exit 1
fi

# Get list of themes
themes=$(ls -1 "$SOURCE_DIR"/*.conf 2>/dev/null | xargs -n1 basename | sed 's/.conf$//')

if [ -z "$themes" ]; then
    notify-send "Theme Switcher" "No themes found!" -u critical
    exit 1
fi

# Use wofi to select theme
selected=$(echo "$themes" | wofi --dmenu --prompt "Select Theme" --cache-file /dev/null)

if [ -z "$selected" ]; then
    exit 0
fi

theme_file="$SOURCE_DIR/${selected}.conf"

if [ ! -f "$theme_file" ]; then
    notify-send "Theme Switcher" "Theme file not found: $selected" -u critical
    exit 1
fi

# Copy theme to current
cp "$theme_file" "$CURRENT_THEME"

# Reload Hyprland
hyprctl reload

# Notify user
notify-send "Theme Switcher" "Applied theme: $selected" -i preferences-desktop-theme

echo "Theme '$selected' applied successfully!"
