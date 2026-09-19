import QtQuick
import Quickshell.Services.Mpris
import "components"

Item {
    id: root

    required property var player
    required property Theme theme
    property color pillHover: Qt.lighter(root.theme.primary, 1.12)

    implicitHeight: 44

    function cycleLoop() {
        if (root.player === null) return
        switch (root.player.loopState) {
            case MprisLoopState.None: root.player.loopState = MprisLoopState.Playlist; break
            case MprisLoopState.Playlist: root.player.loopState = MprisLoopState.Track; break
            default: root.player.loopState = MprisLoopState.None
        }
    }

    // ---- Play button (pill) ----
    Rectangle {
        id: playButton
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        property bool enabled: root.player !== null && root.player.canTogglePlaying

        width: 64
        height: 40
        radius: height / 2
        opacity: enabled ? 1 : 0.4
        scale: hover.pressed ? 0.92 : 1
        color: hover.hovered ? root.pillHover : root.theme.primary
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on opacity { NumberAnimation { duration: 120 } }
        Behavior on scale { NumberAnimation { duration: 100 } }

        function playPulse() {
            pulseAnim.restart()
        }

        Text {
            id: playIcon
            anchors.centerIn: parent
            text: root.player !== null && root.player.isPlaying ? "\uf04c" : "\uf04b"
            color: root.theme.pillFg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 21
        }

        SequentialAnimation {
            id: pulseAnim
            running: false
            NumberAnimation {
                target: playIcon
                property: "scale"
                to: 1.3
                duration: 90
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: playIcon
                property: "scale"
                to: 1
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            enabled: playButton.enabled
            onClicked: if (root.player !== null) root.player.togglePlaying()
        }
    }

    Connections {
        target: root.player
        function onPlaybackStateChanged() {
            if (root.player !== null) playButton.playPulse()
        }
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        IconButton {
            icon: "\uf048"
            theme: root.theme
            enabled: root.player !== null && root.player.canGoPrevious
            onClicked: if (root.player !== null) root.player.previous()
        }

        IconButton {
            icon: "\uf051"
            theme: root.theme
            enabled: root.player !== null && root.player.canGoNext
            onClicked: if (root.player !== null) root.player.next()
        }

        IconButton {
            icon: root.player !== null && root.player.loopState === MprisLoopState.Track ? "\uf2fa" : "\uf2f9"
            active: root.player !== null && root.player.loopState !== MprisLoopState.None
            theme: root.theme
            enabled: root.player !== null && root.player.canControl && root.player.loopSupported
            onClicked: root.cycleLoop()
        }

        IconButton {
            icon: "\uf074"
            active: root.player !== null && root.player.shuffle
            theme: root.theme
            enabled: root.player !== null && root.player.canControl && root.player.shuffleSupported
            onClicked: if (root.player !== null) root.player.shuffle = !root.player.shuffle
        }
    }
}
