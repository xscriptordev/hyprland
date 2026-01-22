#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Theme Switcher - Hyprland, Waybar, and Kitty                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

CONFIG_DIR="$HOME/.config/hypr"
THEMES_DIR="$CONFIG_DIR/themes"
CURRENT_THEME="$CONFIG_DIR/theme.conf"
WAYBAR_THEMES="$HOME/.config/waybar/themes"
WAYBAR_CURRENT="$HOME/.config/waybar/current-theme.css"
KITTY_THEMES="$HOME/.config/kitty/themes"
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
KITTY_CURRENT="$HOME/.config/kitty/current-theme.conf"
ROFI_DIR="$HOME/.config/rofi"
ROFI_COLORS="$ROFI_DIR/colors.rasi"

# Fallback paths
SCRIPT_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
if [ ! -d "$THEMES_DIR" ]; then
    THEMES_DIR="$SCRIPT_DIR/themes"
fi
if [ ! -d "$WAYBAR_THEMES" ]; then
    WAYBAR_THEMES="$SCRIPT_DIR/config/waybar/themes"
fi
if [ ! -d "$KITTY_THEMES" ]; then
    KITTY_THEMES="$SCRIPT_DIR/config/kitty/themes"
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
    kitty_theme="$KITTY_THEMES/${selected}.conf"
    
    if [ ! -f "$theme_file" ]; then
        notify-send "Theme Switcher" "Theme not found: $selected" -u critical
        exit 1
    fi

    mkdir -p "$ROFI_DIR"

    get_hex() {
        local key="$1"
        awk -v key="$key" '
            $1 == key {
                if (match($0, /rgb\(([0-9a-fA-F]{6})\)/, m)) {
                    print m[1]
                    exit
                }
            }
        ' "$theme_file"
    }

    accent_hex=$(get_hex '$color1')
    accent2_hex=$(get_hex '$color5')
    fg_hex=$(get_hex '$color7')

    accent_hex=${accent_hex:-fc618d}
    accent2_hex=${accent2_hex:-948ae3}
    fg_hex=${fg_hex:-f7f1ff}

    cat > "$ROFI_COLORS" <<EOF
* {
    background: #000000f2;
    foreground: #${fg_hex};
    accent: #${accent_hex};
    accent2: #${accent2_hex};
}
EOF
    
    # ┌─────────────────────────────────────────────────────────────────────────┐
    # │ Apply Hyprland theme                                                    │
    # └─────────────────────────────────────────────────────────────────────────┘
    cp "$theme_file" "$CURRENT_THEME"
    
    # ┌─────────────────────────────────────────────────────────────────────────┐
    # │ Apply Waybar theme                                                      │
    # └─────────────────────────────────────────────────────────────────────────┘
    if [ -f "$waybar_css" ]; then
        cp "$waybar_css" "$WAYBAR_CURRENT"
    else
        if [ -f "$WAYBAR_THEMES/x.css" ]; then
            cp "$WAYBAR_THEMES/x.css" "$WAYBAR_CURRENT"
        fi
    fi
    
    # ┌─────────────────────────────────────────────────────────────────────────┐
    # │ Apply Kitty theme                                                       │
    # └─────────────────────────────────────────────────────────────────────────┘
    if [ -f "$kitty_theme" ]; then
        cp "$kitty_theme" "$KITTY_CURRENT"
        
        # Reload Kitty if running - send SIGUSR1 to reload config
        pkill -USR1 kitty 2>/dev/null
    else
        if [ -f "$KITTY_THEMES/x.conf" ]; then
            cp "$KITTY_THEMES/x.conf" "$KITTY_CURRENT"
            pkill -USR1 kitty 2>/dev/null
        fi
    fi
    
    # ┌─────────────────────────────────────────────────────────────────────────┐
    # │ Reload components                                                       │
    # └─────────────────────────────────────────────────────────────────────────┘
    
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
