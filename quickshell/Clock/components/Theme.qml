import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    // ---- Material You color roles ----
    property color primary: "#D0BCFF"
    property color pillFg: "#141218"
    property color surface: Qt.rgba(0.09, 0.09, 0.11, 0.56)
    property color surfaceContainer: Qt.rgba(0.16, 0.14, 0.16, 0.56)
    property color surfaceContainerHigh: "#2A2830"
    property color fg: "#E6E1E5"
    property color fgMuted: "#9A95A3"
    property color outline: Qt.rgba(1, 1, 1, 0.07)
    property color powPerf: "#FF8A80"
    property color powSave: "#69F0AE"

    // ---- fonts ----
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    readonly property string uiFont: "Inter"
    readonly property string emojiFont: "Noto Color Emoji"

    readonly property string colorsPath: Quickshell.env("HOME") + "/.config/quickshell/colors.json"

    function hexToRgba(hex) {
        hex = String(hex || "").replace("#", "")
        if (hex.length !== 6 && hex.length !== 8) return "#000000"
        const r = parseInt(hex.slice(0, 2), 16) / 255
        const g = parseInt(hex.slice(2, 4), 16) / 255
        const b = parseInt(hex.slice(4, 6), 16) / 255
        const a = hex.length === 8 ? parseInt(hex.slice(6, 8), 16) / 255 : 1
        return Qt.rgba(r, g, b, a)
    }

    function applyColors(text) {
        try {
            const c = JSON.parse(text)
            root.primary = root.hexToRgba(c.accent)
            root.pillFg = root.hexToRgba(c.pillFg)
            root.surface = root.hexToRgba(c.bg)
            root.surfaceContainer = root.hexToRgba(c.pillBg)
            root.surfaceContainerHigh = root.hexToRgba(c.trackBg)
            root.fg = root.hexToRgba(c.fg)
            root.fgMuted = root.hexToRgba(c.fgMuted)
            root.outline = root.hexToRgba(c.border)
        } catch (e) {
            console.log("Quickshell Theme: failed to load colors: " + e)
        }
    }

    // ---- live color watcher ----
    FileView {
        id: colorFile
        path: root.colorsPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.applyColors(text())
        onLoadFailed: (error) => console.log("Quickshell Theme: colors.json load failed: " + error)
    }
}
