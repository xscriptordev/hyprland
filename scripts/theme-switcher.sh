#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Theme Switcher Script with Waybar Integration                             ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

CONFIG_DIR="$HOME/.config/hypr"
THEMES_DIR="$CONFIG_DIR/themes"
CURRENT_THEME="$CONFIG_DIR/theme.conf"
WAYBAR_CSS="$HOME/.config/waybar/style.css"

# Fallback to script directory themes
SCRIPT_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
if [ ! -d "$THEMES_DIR" ]; then
    THEMES_DIR="$SCRIPT_DIR/themes"
fi

# Get list of themes
get_themes() {
    ls -1 "$THEMES_DIR"/*.conf 2>/dev/null | xargs -n1 basename | sed 's/.conf$//'
}

# Extract color from theme file and return clean hex
get_color_hex() {
    local theme_file="$1"
    local color_name="$2"
    local color=$(grep "^\$$color_name" "$theme_file" | sed 's/.*= *//' | tr -d ' ')
    # Ensure it starts with #
    if [[ ! "$color" =~ ^# ]]; then
        color="#$color"
    fi
    # Remove any trailing characters after 7 chars (#RRGGBB)
    echo "${color:0:7}"
}

# Convert hex color to rgba string
hex_to_rgba() {
    local hex="$1"
    local alpha="$2"
    # Remove # if present
    hex="${hex#\#}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "rgba($r, $g, $b, $alpha)"
}

# Generate Waybar CSS from theme
generate_waybar_css() {
    local theme_file="$1"
    local theme_name=$(basename "$theme_file" .conf)
    
    # Extract colors as hex
    local c0=$(get_color_hex "$theme_file" "color0")
    local c1=$(get_color_hex "$theme_file" "color1")
    local c2=$(get_color_hex "$theme_file" "color2")
    local c3=$(get_color_hex "$theme_file" "color3")
    local c4=$(get_color_hex "$theme_file" "color4")
    local c5=$(get_color_hex "$theme_file" "color5")
    local c6=$(get_color_hex "$theme_file" "color6")
    local c7=$(get_color_hex "$theme_file" "color7")
    local c8=$(get_color_hex "$theme_file" "color8")
    
    # Pre-compute rgba values
    local bg_main=$(hex_to_rgba "$c0" "0.92")
    local border_accent=$(hex_to_rgba "$c1" "0.6")
    local border_secondary=$(hex_to_rgba "$c5" "0.4")
    local border_dim=$(hex_to_rgba "$c8" "0.4")
    local border_cyan=$(hex_to_rgba "$c6" "0.4")
    local border_green=$(hex_to_rgba "$c2" "0.4")
    local hover_accent=$(hex_to_rgba "$c1" "0.8")
    local hover_secondary=$(hex_to_rgba "$c5" "0.8")
    local hover_cyan=$(hex_to_rgba "$c6" "0.2")
    local hover_purple=$(hex_to_rgba "$c5" "0.2")
    local hover_green=$(hex_to_rgba "$c2" "0.2")
    local hover_dim=$(hex_to_rgba "$c8" "0.5")
    local critical_bg=$(hex_to_rgba "$c1" "0.2")
    local tooltip_bg=$(hex_to_rgba "$c0" "0.95")
    
    cat > "$WAYBAR_CSS" << CSSEOF
/* Waybar Styles - Theme: ${theme_name} */

* {
    font-family: "JetBrainsMono Nerd Font", "Noto Sans", monospace;
    font-size: 13px;
    font-weight: 500;
    min-height: 0;
    padding: 0;
    margin: 0;
}

window#waybar {
    background: transparent;
    color: ${c7};
}

window#waybar > box {
    background: transparent;
    padding: 0;
}

#custom-logo {
    background: ${bg_main};
    border: 2px solid ${border_accent};
    border-radius: 12px;
    padding: 4px 14px;
    margin: 4px 4px 4px 0;
    color: ${c1};
    font-size: 14px;
    font-weight: bold;
}

#workspaces {
    background: ${bg_main};
    border: 2px solid ${border_secondary};
    border-radius: 12px;
    margin: 4px;
    padding: 0 4px;
}

#workspaces button {
    padding: 4px 10px;
    margin: 4px 2px;
    color: ${c8};
    background: transparent;
    border: none;
    border-radius: 8px;
}

#workspaces button:hover {
    background: ${hover_dim};
    color: ${c7};
}

#workspaces button.active {
    background: ${c1};
    color: ${c7};
    font-weight: bold;
}

#workspaces button.urgent {
    background: ${c4};
    color: ${c7};
}

#clock {
    background: ${bg_main};
    border: 2px solid ${border_accent};
    border-radius: 12px;
    padding: 4px 18px;
    margin: 4px;
    color: ${c7};
    font-weight: 600;
}

#clock:hover {
    background: ${hover_accent};
    border-color: ${c1};
}

#tray {
    background: ${bg_main};
    border: 2px solid ${border_dim};
    border-radius: 12px;
    padding: 4px 10px;
    margin: 4px;
}

#cpu {
    background: ${bg_main};
    border: 2px solid ${border_cyan};
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: ${c6};
}

#cpu:hover {
    background: ${hover_cyan};
    border-color: ${c6};
}

#memory {
    background: ${bg_main};
    border: 2px solid ${border_secondary};
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: ${c5};
}

#memory:hover {
    background: ${hover_purple};
    border-color: ${c5};
}

#pulseaudio {
    background: ${bg_main};
    border: 2px solid ${border_green};
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: ${c2};
}

#pulseaudio:hover {
    background: ${hover_green};
    border-color: ${c2};
}

#pulseaudio.muted {
    color: ${c1};
    border-color: ${border_accent};
}

#network {
    background: ${bg_main};
    border: 2px solid ${border_cyan};
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: ${c6};
}

#network:hover {
    background: ${hover_cyan};
    border-color: ${c6};
}

#network.disconnected {
    color: ${c1};
    border-color: ${border_accent};
}

#battery {
    background: ${bg_main};
    border: 2px solid ${border_green};
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: ${c2};
}

#battery:hover {
    background: ${hover_green};
    border-color: ${c2};
}

#battery.charging {
    color: ${c3};
}

#battery.warning:not(.charging) {
    color: ${c4};
}

#battery.critical:not(.charging) {
    color: ${c1};
    border-color: ${c1};
    background: ${critical_bg};
}

#custom-power {
    background: ${c1};
    border: none;
    border-radius: 12px;
    padding: 4px 14px;
    margin: 4px 0 4px 4px;
    color: ${c7};
    font-size: 14px;
}

#custom-power:hover {
    background: ${c5};
}

tooltip {
    background: ${tooltip_bg};
    border: 2px solid ${c1};
    border-radius: 10px;
}

tooltip label {
    color: ${c7};
    padding: 6px;
}
CSSEOF
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
    
    if [ ! -f "$theme_file" ]; then
        notify-send "Theme Switcher" "Theme file not found: $selected" -u critical
        exit 1
    fi
    
    # Copy theme to current
    cp "$theme_file" "$CURRENT_THEME"
    
    # Generate Waybar CSS with new colors
    generate_waybar_css "$theme_file"
    
    # Reload Hyprland
    hyprctl reload
    
    # Restart Waybar
    killall waybar 2>/dev/null
    sleep 0.5
    waybar &
    disown
    
    # Notify user
    notify-send "Theme Switcher" "Applied: $selected" -i preferences-desktop-theme
}

main "$@"
