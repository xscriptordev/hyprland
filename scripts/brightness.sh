#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Brightness Control Script                                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

STEP=5

clamp() {
    local v="$1"
    local min="$2"
    local max="$3"
    if [ "$v" -lt "$min" ]; then
        echo "$min"
        return
    fi
    if [ "$v" -gt "$max" ]; then
        echo "$max"
        return
    fi
    echo "$v"
}

set_backlight() {
    local direction="$1"
    if ! command -v brightnessctl >/dev/null 2>&1; then
        return 1
    fi

    if [ "$direction" = "up" ]; then
        brightnessctl set +${STEP}% >/dev/null 2>&1 || return 1
        return 0
    fi
    if [ "$direction" = "down" ]; then
        brightnessctl set ${STEP}%- >/dev/null 2>&1 || return 1
        return 0
    fi
    return 1
}

ddc_displays() {
    command -v ddcutil >/dev/null 2>&1 || return 1
    ddcutil detect --brief 2>/dev/null | awk '/^Display [0-9]+/ {print $2}'
}

ddc_get_brightness() {
    local display="$1"
    ddcutil -d "$display" getvcp 10 --brief 2>/dev/null | awk -F'[:,=]' '{gsub(/[^0-9]/, "", $3); print $3; exit}'
}

ddc_set_brightness() {
    local display="$1"
    local value="$2"
    ddcutil -d "$display" setvcp 10 "$value" >/dev/null 2>&1
}

set_ddc() {
    local direction="$1"
    local displays
    displays=$(ddc_displays)
    [ -z "$displays" ] && return 1

    local ok=0
    while IFS= read -r d; do
        [ -z "$d" ] && continue
        current=$(ddc_get_brightness "$d")
        [ -z "$current" ] && continue
        if [ "$direction" = "up" ]; then
            target=$(clamp $((current + STEP)) 0 100)
        else
            target=$(clamp $((current - STEP)) 0 100)
        fi
        if ddc_set_brightness "$d" "$target"; then
            ok=1
        fi
    done <<< "$displays"

    [ "$ok" -eq 1 ]
}

get_brightness() {
    brightnessctl -m | cut -d',' -f4 | tr -d '%'
}

send_notification() {
    brightness=$(get_brightness)
    
    if [ "$brightness" -lt 33 ]; then
        icon="display-brightness-low"
    elif [ "$brightness" -lt 66 ]; then
        icon="display-brightness-medium"
    else
        icon="display-brightness-high"
    fi
    
    notify-send -h int:value:"$brightness" -h string:x-canonical-private-synchronous:brightness "Brightness" "$brightness%" -i "$icon" -t 1500
}

case "$1" in
    up)
        if set_backlight up || set_ddc up; then
            send_notification
            exit 0
        fi
        notify-send "Brightness" "No brightness backend available" -u critical
        ;;
    down)
        if set_backlight down || set_ddc down; then
            send_notification
            exit 0
        fi
        notify-send "Brightness" "No brightness backend available" -u critical
        ;;
    *)
        echo "Usage: $0 {up|down}"
        exit 1
        ;;
esac
