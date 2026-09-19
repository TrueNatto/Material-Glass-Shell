#!/usr/bin/env bash
device="${1:?usage: OSDWidget.sh volume|brightness <action>}"
action="${2:-up}"
step=5

OSD_PATH="$HOME/.config/quickshell/OSD"
OSD_PATTERN='[q]uickshell -p .*quickshell/OSD'
STATE_FILE='/tmp/quickshell-osd-state.json'
GEN_STAMP='/tmp/quickshell-osd-gen'

show() {
    if pgrep -f '[q]uickshell -p .*Center/shell.qml' >/dev/null 2>&1; then
        return 0
    fi

    GEN=$(date +%s%N)
    echo "$GEN" > "$GEN_STAMP"
    printf '{"kind":"%s","value":%s,"muted":%s}\n' "$1" "$2" "$3" > "$STATE_FILE.tmp"
    mv "$STATE_FILE.tmp" "$STATE_FILE"

    if ! pgrep -f "$OSD_PATTERN" >/dev/null 2>&1; then
        QS_NO_RELOAD_POPUP=1 setsid quickshell -p "$OSD_PATH" >/dev/null 2>&1 &
    fi

    (
        sleep 4.5
        [ "$(cat "$GEN_STAMP" 2>/dev/null)" = "$GEN" ] && {
            pkill -f "$OSD_PATTERN" 2>/dev/null
            rm -f "$STATE_FILE"
        }
    ) &
}

case "$device" in
    volume)
        case "$action" in
            up)   wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "${step}%+" ;;
            down) wpctl set-volume @DEFAULT_AUDIO_SINK@ "${step}%-" ;;
            mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
            *)    echo "unknown action: $action (up|down|mute)" >&2; exit 1 ;;
        esac

        raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
        pct=$(echo "$raw" | grep -oE '[0-9]+\.[0-9]+' | head -1 | awk '{printf "%.0f", $1 * 100}')
        [ -z "$pct" ] && pct=0
        [ "$pct" -gt 100 ] && pct=100
        muted=false
        echo "$raw" | grep -qi "MUTED" && muted=true

        show volume "$pct" "$muted"
        ;;
    brightness)
        case "$action" in
            up)   brightnessctl set "${step}%+" ;;
            down) brightnessctl set "${step}%-" ;;
            *)    echo "unknown action: $action (up|down)" >&2; exit 1 ;;
        esac

        pct=$(brightnessctl -m 2>/dev/null | head -1 | cut -d, -f4 | tr -d '%')
        [ -z "$pct" ] && pct=0

        show brightness "$pct" false
        ;;
    *)
        echo "unknown device: $device (volume|brightness)" >&2; exit 1
        ;;
esac