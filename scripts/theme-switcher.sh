#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Theme Switcher - Uses pre-built CSS files                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

CONFIG_DIR="$HOME/.config/hypr"
THEMES_DIR="$CONFIG_DIR/themes"
CURRENT_THEME="$CONFIG_DIR/theme.conf"
WAYBAR_THEMES="$HOME/.config/waybar/themes"
WAYBAR_CURRENT="$HOME/.config/waybar/current-theme.css"

# Fallback paths
SCRIPT_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
if [ ! -d "$THEMES_DIR" ]; then
    THEMES_DIR="$SCRIPT_DIR/themes"
fi
if [ ! -d "$WAYBAR_THEMES" ]; then
    WAYBAR_THEMES="$SCRIPT_DIR/config/waybar/themes"
fi

# Get list of themes
get_themes() {
    ls -1 "$THEMES_DIR"/*.conf 2>/dev/null | xargs -n1 basename | sed 's/.conf$//'
}

# Main function
main() {
    themes=$(get_themes)
    
    if [ -z "$themes" ]; then
        notify-send "Theme Switcher" "No themes found!" -u critical
        exit 1
    fi
    
    # Use wofi to select theme
    selected=$(echo "$themes" | wofi --dmenu --prompt "Select Theme" --cache-file /dev/null)
    
    if [ -z "$selected" ]; then
        exit 0
    fi
    
    theme_file="$THEMES_DIR/${selected}.conf"
    waybar_css="$WAYBAR_THEMES/${selected}.css"
    
    if [ ! -f "$theme_file" ]; then
        notify-send "Theme Switcher" "Theme not found: $selected" -u critical
        exit 1
    fi
    
    # Copy Hyprland theme
    cp "$theme_file" "$CURRENT_THEME"
    
    # Copy Waybar theme CSS if exists
    if [ -f "$waybar_css" ]; then
        cp "$waybar_css" "$WAYBAR_CURRENT"
    else
        # Fallback to X theme
        if [ -f "$WAYBAR_THEMES/x.css" ]; then
            cp "$WAYBAR_THEMES/x.css" "$WAYBAR_CURRENT"
        fi
        notify-send "Theme Switcher" "Waybar theme not found, using X" -u low
    fi
    
    # Reload Hyprland
    hyprctl reload
    
    # Restart Waybar
    killall waybar 2>/dev/null
    sleep 0.3
    waybar &
    disown
    
    notify-send "Theme Switcher" "Applied: $selected" -i preferences-desktop-theme
}

main "$@"
