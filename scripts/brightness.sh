#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Brightness Control Script                                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

STEP=5

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
        brightnessctl set +${STEP}%
        send_notification
        ;;
    down)
        brightnessctl set ${STEP}%-
        send_notification
        ;;
    *)
        echo "Usage: $0 {up|down}"
        exit 1
        ;;
esac
