import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "components"
ShellRoot {
    id: root
    property Theme theme: Theme {}
    readonly property string statePath: "/tmp/quickshell-osd-state.json"
    function clamp01(v) { return Math.max(0, Math.min(1, v)) }
    function applyState() {
        const raw = stateFile.text().trim()
        if (raw === "") return
        try {
            const s = JSON.parse(raw)
            if (s.kind === "brightness") {
                root.briFraction = root.clamp01(parseFloat(s.value) / 100)
                if (pillBrightness.opacity < 1) briEnter.start()
            } else {
                root.volFraction = root.clamp01(parseFloat(s.value) / 100)
                root.volMuted = !!s.muted
                if (pillVolume.opacity < 1) volEnter.start()
            }
        } catch (e) {
            console.log("Quickshell OSD: failed to parse state: " + e)
        }
    }
    property real volFraction: 0
    property bool volMuted: false
    property real briFraction: 0
    FileView {
        id: stateFile
        path: root.statePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.applyState()
    }
    Component.onCompleted: root.applyState()
    ParallelAnimation {
        id: volEnter
        NumberAnimation { target: pillVolume; property: "opacity"; to: 1; duration: 180; easing.type: Easing.OutCubic }
        NumberAnimation { target: pillVolume; property: "anchors.rightMargin"; to: 0; duration: 240; easing.type: Easing.OutCubic }
        NumberAnimation { target: pillVolume; property: "scale"; to: 1; duration: 240; easing.type: Easing.OutBack }
    }
    ParallelAnimation {
        id: briEnter
        NumberAnimation { target: pillBrightness; property: "opacity"; to: 1; duration: 180; easing.type: Easing.OutCubic }
        NumberAnimation { target: pillBrightness; property: "anchors.rightMargin"; to: 0; duration: 240; easing.type: Easing.OutCubic }
        NumberAnimation { target: pillBrightness; property: "scale"; to: 1; duration: 240; easing.type: Easing.OutBack }
    }
    PanelWindow {
        visible: true
        color: "transparent"
        WlrLayershell.namespace: "quickshell:osd"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        anchors.top: true
        anchors.bottom: true
        anchors.right: true
        margins.right: 18
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}
        implicitWidth: 100
        implicitHeight: 900
        OSDPill {
            id: pillVolume
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.25
            anchors.rightMargin: -22
            opacity: 0
            scale: 0.92
            kind: "volume"
            fraction: root.volFraction
            muted: root.volMuted
            accent: root.theme.primary
            mutedColor: root.theme.fgMuted
            trackBg: root.theme.surfaceContainerHigh
            chipBg: root.theme.surfaceContainer
            onChip: root.theme.fg
        }
        OSDPill {
            id: pillBrightness
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height * 0.25 - 15
            anchors.rightMargin: -22
            opacity: 0
            scale: 0.92
            kind: "brightness"
            fraction: root.briFraction
            muted: false
            accent: root.theme.primary
            mutedColor: root.theme.fgMuted
            trackBg: root.theme.surfaceContainerHigh
            chipBg: root.theme.surfaceContainer
            onChip: root.theme.fg
        }
    }
}
