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

# Extract color from theme file (removes # prefix if present)
get_color() {
    local theme_file="$1"
    local color_name="$2"
    grep "^\$$color_name" "$theme_file" | sed 's/.*= *//' | tr -d ' ' | sed 's/#//'
}

# Convert hex to RGB values
hex_to_rgb() {
    local hex="$1"
    # Remove # if present
    hex="${hex#\#}"
    # Extract RGB
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "$r, $g, $b"
}

# Generate Waybar CSS from theme
generate_waybar_css() {
    local theme_file="$1"
    local theme_name=$(basename "$theme_file" .conf)
    
    # Extract colors from theme (as hex without #)
    local color0=$(get_color "$theme_file" "color0")
    local color1=$(get_color "$theme_file" "color1")
    local color2=$(get_color "$theme_file" "color2")
    local color3=$(get_color "$theme_file" "color3")
    local color4=$(get_color "$theme_file" "color4")
    local color5=$(get_color "$theme_file" "color5")
    local color6=$(get_color "$theme_file" "color6")
    local color7=$(get_color "$theme_file" "color7")
    local color8=$(get_color "$theme_file" "color8")
    
    # Convert to RGB for rgba()
    local rgb0=$(hex_to_rgb "$color0")
    local rgb1=$(hex_to_rgb "$color1")
    local rgb2=$(hex_to_rgb "$color2")
    local rgb5=$(hex_to_rgb "$color5")
    local rgb6=$(hex_to_rgb "$color6")
    local rgb8=$(hex_to_rgb "$color8")
    
    # Generate CSS
    cat > "$WAYBAR_CSS" << EOF
/* Waybar Styles - Theme: ${theme_name} (Auto-generated) */

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
    color: #${color7};
}

window#waybar > box {
    background: transparent;
    padding: 0;
}

#custom-logo {
    background: rgba(${rgb0}, 0.92);
    border: 2px solid rgba(${rgb1}, 0.6);
    border-radius: 12px;
    padding: 4px 14px;
    margin: 4px 4px 4px 0;
    color: #${color1};
    font-size: 14px;
    font-weight: bold;
}

#workspaces {
    background: rgba(${rgb0}, 0.92);
    border: 2px solid rgba(${rgb5}, 0.4);
    border-radius: 12px;
    margin: 4px;
    padding: 0 4px;
}

#workspaces button {
    padding: 4px 10px;
    margin: 4px 2px;
    color: #${color8};
    background: transparent;
    border: none;
    border-radius: 8px;
}

#workspaces button:hover {
    background: rgba(${rgb8}, 0.5);
    color: #${color7};
}

#workspaces button.active {
    background: linear-gradient(135deg, #${color1}, #${color5});
    color: #${color7};
    font-weight: bold;
}

#workspaces button.urgent {
    background: #${color4};
    color: #${color7};
}

#clock {
    background: rgba(${rgb0}, 0.92);
    border: 2px solid rgba(${rgb1}, 0.4);
    border-radius: 12px;
    padding: 4px 18px;
    margin: 4px;
    color: #${color7};
    font-weight: 600;
}

#clock:hover {
    background: linear-gradient(135deg, rgba(${rgb1}, 0.8), rgba(${rgb5}, 0.8));
    border-color: #${color1};
}

#tray {
    background: rgba(${rgb0}, 0.92);
    border: 2px solid rgba(${rgb8}, 0.4);
    border-radius: 12px;
    padding: 4px 10px;
    margin: 4px;
}

#cpu {
    background: rgba(${rgb0}, 0.92);
    border: 2px solid rgba(${rgb6}, 0.4);
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: #${color6};
}

#cpu:hover {
    background: rgba(${rgb6}, 0.2);
    border-color: #${color6};
}

#memory {
    background: rgba(${rgb0}, 0.92);
    border: 2px solid rgba(${rgb5}, 0.4);
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: #${color5};
}

#memory:hover {
    background: rgba(${rgb5}, 0.2);
    border-color: #${color5};
}

#pulseaudio {
    background: rgba(${rgb0}, 0.92);
    border: 2px solid rgba(${rgb2}, 0.4);
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: #${color2};
}

#pulseaudio:hover {
    background: rgba(${rgb2}, 0.2);
    border-color: #${color2};
}

#pulseaudio.muted {
    color: #${color1};
    border-color: rgba(${rgb1}, 0.4);
}

#network {
    background: rgba(${rgb0}, 0.92);
    border: 2px solid rgba(${rgb6}, 0.4);
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: #${color6};
}

#network:hover {
    background: rgba(${rgb6}, 0.2);
    border-color: #${color6};
}

#network.disconnected {
    color: #${color1};
    border-color: rgba(${rgb1}, 0.4);
}

#battery {
    background: rgba(${rgb0}, 0.92);
    border: 2px solid rgba(${rgb2}, 0.4);
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: #${color2};
}

#battery:hover {
    background: rgba(${rgb2}, 0.2);
    border-color: #${color2};
}

#battery.charging {
    color: #${color3};
}

#battery.warning:not(.charging) {
    color: #${color4};
}

#battery.critical:not(.charging) {
    color: #${color1};
    border-color: #${color1};
    background: rgba(${rgb1}, 0.2);
}

#custom-power {
    background: linear-gradient(135deg, #${color1}, #${color5});
    border: none;
    border-radius: 12px;
    padding: 4px 14px;
    margin: 4px 0 4px 4px;
    color: #${color7};
    font-size: 14px;
}

#custom-power:hover {
    background: #${color1};
}

tooltip {
    background: rgba(${rgb0}, 0.95);
    border: 2px solid #${color1};
    border-radius: 10px;
}

tooltip label {
    color: #${color7};
    padding: 6px;
}
EOF
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
    sleep 0.3
    waybar &
    
    # Notify user
    notify-send "Theme Switcher" "Applied theme: $selected" -i preferences-desktop-theme
    
    echo "Theme '$selected' applied successfully!"
}

main "$@"
