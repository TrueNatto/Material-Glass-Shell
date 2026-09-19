#!/usr/bin/env sh
if pkill -f '([q]s|[q]uickshell) -p .*Clock/shell.qml' 2>/dev/null; then
    exit 0
fi

QS_NO_RELOAD_POPUP=1 exec quickshell -p "$HOME/.config/quickshell/Clock/shell.qml"
