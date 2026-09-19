import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import "components"
ShellRoot {
    id: root
    property Theme theme: Theme {}
    readonly property var players: {
        const all = Mpris.players.values
        const result = []
        for (const p of all) {
            const dbus = (p.dbusName || "").toLowerCase()
            if (!dbus.includes("playerctl")) result.push(p)
        }
        return result
    }
    readonly property int playerCount: root.players.length
    property int playerIndex: -1
    readonly property int currentIndex: {
        if (root.playerIndex >= 0) return Math.min(root.playerIndex, root.players.length - 1)
        for (let i = 0; i < root.players.length; i++)
            if (root.players[i].playbackState === MprisPlaybackState.Playing) return i
        return 0
    }
    readonly property var player: root.players.length > 0 ? root.players[root.currentIndex] : null
    readonly property bool hasPlayer: player !== null
    onPlayersChanged: if (root.playerIndex >= root.players.length) root.playerIndex = -1
    function selectPlayer(i) {
        if (root.players.length === 0) return
        root.playerIndex = (i + root.players.length) % root.players.length
    }
    PanelWindow {
        visible: root.hasPlayer
        WlrLayershell.namespace: "quickshell:mediaPlayer"
        WlrLayershell.layer: WlrLayer.Overlay
        anchors.top: true
        anchors.left: true
        margins.top: 55
        margins.left: 5
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        implicitWidth: 430
        implicitHeight: content.item ? content.item.height : 0
        Loader {
            id: content
            width: parent.width
            active: root.hasPlayer
            sourceComponent: Rectangle {
                width: parent.width
                height: row.implicitHeight + 36
                radius: 26
                color: theme.surface
                border.width: 1
                border.color: theme.outline
                Row {
                    id: row
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16
                    layoutDirection: Qt.RightToLeft
                    Item {
                        id: vPill
                        width: 50
                        height: contentCol.implicitHeight
                        readonly property real position: root.player !== null ? root.player.position : 0
                        readonly property real length: root.player !== null ? root.player.length : 0
                        readonly property real fraction: vPill.length > 0 ? Math.min(1, Math.max(0, vPill.position / vPill.length)) : 0
                        property real displayFraction: 0
                        property bool dragging: false
                        function fmt(sec) {
                            if (sec === undefined || sec === null || isNaN(sec) || sec < 0) sec = 0
                            sec = Math.floor(sec)
                            const h = Math.floor(sec / 3600)
                            const m = Math.floor((sec % 3600) / 60)
                            const s = sec % 60
                            const pad = n => n < 10 ? "0" + n : "" + n
                            return h > 0 ? `${h}:${pad(m)}:${pad(s)}` : `${m}:${pad(s)}`
                        }
                        onFractionChanged: {
                            if (vPill.dragging) return
                            vPill.displayFraction = vPill.fraction
                        }
                        Timer {
                            interval: 1000
                            repeat: true
                            running: root.player !== null && root.player.isPlaying
                            onTriggered: {
                                if (root.player === null) return
                                root.player.positionChanged()
                                if (!vPill.dragging) vPill.displayFraction = vPill.fraction
                            }
                        }
                        Connections {
                            target: root.player
                            function onTrackChanged() { vPill.displayFraction = 0 }
                            function onPostTrackChanged() { vPill.displayFraction = 0 }
                        }
                        WaveCanvas {
                            anchors.fill: parent
                            z: 0
                            fraction: vPill.displayFraction
                            color: theme.primary
                            trackBg: theme.surfaceContainerHigh
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 11
                            text: vPill.fmt(vPill.length)
                            color: theme.fgMuted
                            font.family: "Inter"
                            font.weight: Font.Bold
                            font.pixelSize: 11
                            z: 2
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 12
                            text: vPill.fmt(vPill.position)
                            color: theme.fg
                            font.family: "Inter"
                            font.weight: Font.Bold
                            font.pixelSize: 11
                            z: 2
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: root.player !== null && root.player.canSeek && root.player.positionSupported
                            onPressed: mouse => {
                                vPill.dragging = true
                                vPill.displayFraction = Math.min(1, Math.max(0, 1 - mouse.y / height))
                            }
                            onPositionChanged: mouse => {
                                if (pressed) vPill.displayFraction = Math.min(1, Math.max(0, 1 - mouse.y / height))
                            }
                            onReleased: {
                                if (root.player === null || vPill.length <= 0) return
                                root.player.position = vPill.displayFraction * vPill.length
                                vPill.dragging = false
                            }
                        }
                    }
                    Column {
                        id: contentCol
                        width: parent.width - vPill.width - parent.spacing
                        spacing: 10
                        Rectangle {
                            width: parent.width
                            radius: 18
                            color: theme.surfaceContainer
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.05)
                            implicitHeight: controlsOuter.implicitHeight + 20
                            Controls {
                                id: controlsOuter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                player: root.player
                                theme: root.theme
                            }
                        }
                        Rectangle {
                            width: parent.width
                            radius: 18
                            color: theme.surfaceContainer
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.05)
                            implicitHeight: col2.implicitHeight + 20
                            Column {
                                id: col2
                                width: parent.width
                                anchors.top: parent.top
                                anchors.topMargin: 10
                                spacing: 8
                                Column {
                                    width: parent.width
                                    spacing: 3
                                    Item {
                                        id: mRoot
                                        width: Math.min(parent.width, 250)
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        height: Math.max(20, titleText.implicitHeight)
                                        clip: true
                                        readonly property real contentWidth: titleText.implicitWidth + 40
                                        readonly property bool overflow: titleText.implicitWidth > mRoot.width
                                        Item {
                                            id: marquee
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: mRoot.contentWidth
                                            height: mRoot.height
                                            property real offset: 0
                                            x: (mRoot.width - titleText.implicitWidth) / 2 - marquee.offset
                                            Text {
                                                id: titleText
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: implicitWidth
                                                text: root.player !== null ? (root.player.trackTitle || "Unknown Title") : ""
                                                color: theme.fg
                                                font.family: "Inter"
                                                font.weight: Font.Black
                                                font.pixelSize: 17
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            Text {
                                                x: titleText.width + 40
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: implicitWidth
                                                text: root.player !== null ? (root.player.trackTitle || "Unknown Title") : ""
                                                color: theme.fg
                                                font.family: "Inter"
                                                font.weight: Font.Black
                                                font.pixelSize: 17
                                                verticalAlignment: Text.AlignVCenter
                                                visible: mRoot.overflow
                                            }
                                        }
                                        SequentialAnimation {
                                            running: mRoot.overflow
                                            loops: Animation.Infinite
                                            PauseAnimation { duration: 1200 }
                                            NumberAnimation {
                                                target: marquee
                                                property: "offset"
                                                from: 0
                                                to: mRoot.contentWidth
                                                duration: mRoot.contentWidth / 45 * 1000
                                            }
                                        }
                                    }
                                    Text {
                                        width: parent.width
                                        text: root.player !== null ? (root.player.trackArtist || "Unknown Artist") : ""
                                        color: theme.fgMuted
                                        font.family: "Inter"
                                        font.weight: Font.Black
                                        font.pixelSize: 13
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                    }
                                }
                                Item {
                                    id: artRoot
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 180
                                    height: 180
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: width / 2
                                        color: "#0F0F12"
                                        border.width: 2
                                        border.color: "#232329"
                                        Rectangle {
                                            anchors.fill: parent
                                            radius: width / 2
                                            color: "transparent"
                                            border.width: 8
                                            border.color: Qt.rgba(0, 0, 0, 0.35)
                                        }
                                        Item {
                                            id: spinner
                                            anchors.fill: parent
                                            anchors.margins: 16
                                            ClippingRectangle {
                                                anchors.fill: parent
                                                radius: width / 2
                                                color: "#1E1E24"
                                                Image {
                                                    id: art
                                                    anchors.fill: parent
                                                    source: root.player ? root.player.trackArtUrl : ""
                                                    sourceSize: Qt.size(180, 180)
                                                    fillMode: Image.PreserveAspectCrop
                                                    smooth: false
                                                    asynchronous: true
                                                }
                                            }
                                            Text {
                                                anchors.centerIn: parent
                                                text: "\uf001"
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 180 * 0.28
                                                color: "#3A3A44"
                                                visible: art.status !== Image.Ready
                                            }
                                            Rectangle {
                                                anchors.fill: parent
                                                radius: width / 2
                                                color: Qt.rgba(0, 0, 0, 0.08)
                                            }
                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: 180 * 0.11
                                                height: width
                                                radius: width / 2
                                                color: "#15151A"
                                                border.width: 2
                                                border.color: "#000000"
                                            }
                                        }
                                        RotationAnimator {
                                            target: spinner
                                            from: 0
                                            to: 360
                                            duration: 3600
                                            loops: Animation.Infinite
                                            running: true
                                            paused: root.player === null || !root.player.isPlaying
                                        }
                                    }
                                }
                                Item {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    visible: root.playerCount >= 2
                                    implicitWidth: 240
                                    implicitHeight: 34
                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        IconButton {
                                            icon: "\uf053"
                                            theme: root.theme
                                            onClicked: root.selectPlayer(root.currentIndex - 1)
                                        }
                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 150
                                            spacing: 2
                                            Text {
                                                width: parent.width
                                                text: root.player !== null ? (root.player.identity || root.player.dbusName || "Player") : ""
                                                color: theme.fg
                                                font.family: "Inter"
                                                font.weight: Font.Black
                                                font.pixelSize: 13
                                                horizontalAlignment: Text.AlignHCenter
                                                elide: Text.ElideRight
                                            }
                                            Text {
                                                width: parent.width
                                                text: (root.currentIndex + 1) + " / " + root.playerCount
                                                color: theme.fgMuted
                                                font.family: "Inter"
                                                font.weight: Font.Black
                                                font.pixelSize: 11
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                        IconButton {
                                            icon: "\uf054"
                                            theme: root.theme
                                            onClicked: root.selectPlayer(root.currentIndex + 1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
