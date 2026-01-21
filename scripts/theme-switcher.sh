#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Theme Switcher Script with Waybar Integration                             ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

CONFIG_DIR="$HOME/.config/hypr"
THEMES_DIR="$CONFIG_DIR/themes"
CURRENT_THEME="$CONFIG_DIR/theme.conf"
WAYBAR_CSS="$HOME/.config/waybar/style.css"
WAYBAR_TEMPLATE="$CONFIG_DIR/waybar-template.css"

# Fallback to script directory themes
SCRIPT_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
if [ ! -d "$THEMES_DIR" ]; then
    THEMES_DIR="$SCRIPT_DIR/themes"
fi

# Get list of themes
get_themes() {
    ls -1 "$THEMES_DIR"/*.conf 2>/dev/null | xargs -n1 basename | sed 's/.conf$//'
}

# Extract color from theme file
get_color() {
    local theme_file="$1"
    local color_name="$2"
    grep "^\$$color_name" "$theme_file" | sed 's/.*= *//' | tr -d ' '
}

# Generate Waybar CSS from template
generate_waybar_css() {
    local theme_file="$1"
    
    # Extract colors from theme
    local color0=$(get_color "$theme_file" "color0")
    local color1=$(get_color "$theme_file" "color1")
    local color2=$(get_color "$theme_file" "color2")
    local color3=$(get_color "$theme_file" "color3")
    local color4=$(get_color "$theme_file" "color4")
    local color5=$(get_color "$theme_file" "color5")
    local color6=$(get_color "$theme_file" "color6")
    local color7=$(get_color "$theme_file" "color7")
    local color8=$(get_color "$theme_file" "color8")
    
    # Generate CSS with theme colors
    cat > "$WAYBAR_CSS" << EOF
/* ============================================================================
   WAYBAR STYLES - Island Design (Auto-generated from theme)
   Theme: $(basename "$theme_file" .conf)
   ============================================================================ */

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
    color: ${color7};
}

window#waybar > box {
    background: transparent;
    padding: 0;
}

/* Logo Island */
#custom-logo {
    background: rgba(${color0//\#/}, 0.95);
    border: 2px solid ${color1}99;
    border-radius: 12px;
    padding: 4px 14px;
    margin: 4px 4px 4px 0;
    color: ${color1};
    font-size: 14px;
    font-weight: bold;
}

/* Workspaces Island */
#workspaces {
    background: rgba(${color0//\#/}, 0.95);
    border: 2px solid ${color5}66;
    border-radius: 12px;
    margin: 4px;
    padding: 0 4px;
}

#workspaces button {
    padding: 4px 10px;
    margin: 4px 2px;
    color: ${color8};
    background: transparent;
    border: none;
    border-radius: 8px;
    transition: all 0.2s ease;
}

#workspaces button:hover {
    background: ${color8}80;
    color: ${color7};
}

#workspaces button.active {
    background: linear-gradient(135deg, ${color1}, ${color5});
    color: ${color7};
    font-weight: bold;
}

#workspaces button.urgent {
    background: ${color4};
    color: ${color7};
}

/* Clock Island */
#clock {
    background: rgba(${color0//\#/}, 0.95);
    border: 2px solid ${color1}66;
    border-radius: 12px;
    padding: 4px 18px;
    margin: 4px;
    color: ${color7};
    font-weight: 600;
}

#clock:hover {
    background: linear-gradient(135deg, ${color1}cc, ${color5}cc);
    border-color: ${color1};
}

/* Tray Island */
#tray {
    background: rgba(${color0//\#/}, 0.95);
    border: 2px solid ${color8}66;
    border-radius: 12px;
    padding: 4px 10px;
    margin: 4px;
}

/* CPU Island */
#cpu {
    background: rgba(${color0//\#/}, 0.95);
    border: 2px solid ${color6}66;
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: ${color6};
}

#cpu:hover {
    background: ${color6}33;
    border-color: ${color6};
}

/* Memory Island */
#memory {
    background: rgba(${color0//\#/}, 0.95);
    border: 2px solid ${color5}66;
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: ${color5};
}

#memory:hover {
    background: ${color5}33;
    border-color: ${color5};
}

/* Pulseaudio Island */
#pulseaudio {
    background: rgba(${color0//\#/}, 0.95);
    border: 2px solid ${color2}66;
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: ${color2};
}

#pulseaudio:hover {
    background: ${color2}33;
    border-color: ${color2};
}

#pulseaudio.muted {
    color: ${color1};
    border-color: ${color1}66;
}

/* Network Island */
#network {
    background: rgba(${color0//\#/}, 0.95);
    border: 2px solid ${color6}66;
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: ${color6};
}

#network:hover {
    background: ${color6}33;
    border-color: ${color6};
}

#network.disconnected {
    color: ${color1};
    border-color: ${color1}66;
}

/* Battery Island */
#battery {
    background: rgba(${color0//\#/}, 0.95);
    border: 2px solid ${color2}66;
    border-radius: 12px;
    padding: 4px 12px;
    margin: 4px;
    color: ${color2};
}

#battery:hover {
    background: ${color2}33;
    border-color: ${color2};
}

#battery.charging {
    color: ${color3};
    border-color: ${color3}66;
}

#battery.warning:not(.charging) {
    color: ${color4};
    border-color: ${color4}66;
}

#battery.critical:not(.charging) {
    color: ${color1};
    border-color: ${color1};
    background: ${color1}33;
}

/* Power Button Island */
#custom-power {
    background: linear-gradient(135deg, ${color1}, ${color5});
    border: none;
    border-radius: 12px;
    padding: 4px 14px;
    margin: 4px 0 4px 4px;
    color: ${color7};
    font-size: 14px;
}

#custom-power:hover {
    background: ${color1};
}

/* Tooltip */
tooltip {
    background: rgba(${color0//\#/}, 0.95);
    border: 2px solid ${color1};
    border-radius: 10px;
}

tooltip label {
    color: ${color7};
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
    waybar &
    
    # Notify user
    notify-send "Theme Switcher" "Applied theme: $selected" -i preferences-desktop-theme
    
    echo "Theme '$selected' applied successfully!"
}

main "$@"
