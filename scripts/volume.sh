#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Volume Control Script                                                     ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

STEP=5

get_volume() {
    pamixer --get-volume
}

is_muted() {
    pamixer --get-mute
}

send_notification() {
    volume=$(get_volume)
    muted=$(is_muted)
    
    if [ "$muted" = "true" ]; then
        icon="audio-volume-muted"
        text="Muted"
    elif [ "$volume" -eq 0 ]; then
        icon="audio-volume-muted"
        text="$volume%"
    elif [ "$volume" -lt 33 ]; then
        icon="audio-volume-low"
        text="$volume%"
    elif [ "$volume" -lt 66 ]; then
        icon="audio-volume-medium"
        text="$volume%"
    else
        icon="audio-volume-high"
        text="$volume%"
    fi
    
    notify-send -h int:value:"$volume" -h string:x-canonical-private-synchronous:volume "Volume" "$text" -i "$icon" -t 1500
}

case "$1" in
    up)
        pamixer -i $STEP
        send_notification
        ;;
    down)
        pamixer -d $STEP
        send_notification
        ;;
    mute)
        pamixer -t
        send_notification
        ;;
    *)
        echo "Usage: $0 {up|down|mute}"
        exit 1
        ;;
esac
