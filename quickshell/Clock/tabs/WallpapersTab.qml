import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Effects
import "../components"

Item {
    id: root

    required property Theme theme

    // ---- state ----
    readonly property string wallDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property var wallpapers: []          // absolute paths of discovered images
    property string currentWallpaper: "" // currently-active wallpaper path (from awww query)
    property string applyingPath: ""     // image being applied (to guard double clicks)

    readonly property real spacing: 12
    readonly property real cellH: 161
    readonly property real cellW: Math.floor(gridView.width / 3)
    readonly property real tileW: root.cellW - root.spacing

    component WallTile: Item {
        id: tile
        required property string imgPath
        required property bool isCurrent
        required property bool isApplying
        property bool hovered: false
        property bool pressed: false

        width: root.tileW
        height: root.cellH

        Item {
            id: plate
            anchors.fill: parent
            scale: tile.pressed ? 0.94 : (tile.hovered ? 1.03 : 1.0)
            Behavior on scale { NumberAnimation { duration: 110 } }

            Image {
                id: img
                anchors.fill: parent
                source: tile.imgPath
                asynchronous: true
                cache: true
                sourceSize: Qt.size(Math.round(tile.width * 1.5), Math.round(tile.height * 1.5))
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: false
                // Only pay for the offscreen mask render once the image has
                // actually decoded — avoids stacking N simultaneous
                // MultiEffect passes while the grid is populating/animating.
                layer.enabled: img.status === Image.Ready
                layer.smooth: false
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: maskShape
                }
            }

            Rectangle {
                id: maskShape
                anchors.fill: parent
                radius: 12
                color: "white"
                visible: false
                layer.enabled: true
            }

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: Qt.rgba(0.05, 0.05, 0.08, 0.62)
                visible: tile.isApplying
                opacity: tile.isApplying ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 120 } }

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        id: spinText
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "\uf1ce"
                        color: root.theme.primary
                        font.family: root.theme.iconFont
                        font.pixelSize: 26
                        RotationAnimator {
                            target: spinText
                            from: 0
                            to: 360
                            duration: 700
                            loops: Animation.Infinite
                            running: tile.isApplying
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Applying"
                        color: "white"
                        font.family: theme.uiFont
                        font.weight: Font.Black
                        font.pixelSize: 12
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: "transparent"
                border.width: tile.isApplying ? 2.5 : (tile.isCurrent ? 2 : 1.5)
                border.color: tile.isApplying
                             ? root.theme.primary
                             : (tile.isCurrent || tile.hovered ? root.theme.primary : root.theme.surfaceContainerHigh)
                Behavior on border.color { ColorAnimation { duration: 140 } }
                Behavior on border.width { NumberAnimation { duration: 140 } }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: tile.hovered = true
            onExited: {
                tile.hovered = false
                tile.pressed = false
            }
            onPressed: tile.pressed = true
            onReleased: tile.pressed = false
            onClicked: root.applyWallpaper(tile.imgPath)
        }
    }

    Column {
        anchors.fill: parent
        spacing: root.spacing

        Item {
            width: parent.width
            height: 28

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\uf1c5"
                    color: theme.primary
                    font.family: theme.iconFont
                    font.pixelSize: 15
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.wallpapers.length + " wallpapers"
                    color: theme.fgMuted
                    font.family: theme.uiFont
                    font.weight: Font.Black
                    font.pixelSize: 12
                }
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: root.wallDir
                color: theme.fgMuted
                font.family: theme.uiFont
                font.weight: Font.Medium
                font.pixelSize: 10
                opacity: 0.75
            }
        }

        GridView {
            id: gridView
            width: parent.width
            height: parent.height - parent.spacing - 28
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            cacheBuffer: 300
            model: root.wallpapers
            cellWidth: root.cellW
            cellHeight: root.cellH + root.spacing

            delegate: WallTile {
                required property int index
                required property string modelData
                imgPath: modelData
                isCurrent: modelData === root.currentWallpaper
                isApplying: modelData === root.applyingPath
            }
        }
    }

    // ---- empty state overlay (folder missing / no images) ----
    Item {
        anchors.fill: parent
        visible: root.wallpapers.length === 0

        Column {
            anchors.centerIn: parent
            spacing: 12

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "\uf1c5"
                color: theme.fgMuted
                font.family: theme.iconFont
                font.pixelSize: 44
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "No wallpapers found in the Wallpapers folder"
                color: theme.fgMuted
                font.family: theme.uiFont
                font.weight: Font.Black
                font.pixelSize: 13
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.wallDir
                color: theme.fgMuted
                font.family: theme.uiFont
                font.weight: Font.Medium
                font.pixelSize: 11
                opacity: 0.7
            }
        }
    }

    property string pendingPath: ""

    function startApply(path) {
        root.applyingPath = path
        applyProc.command = ["awww", "img", "--transition-type", "outer",
                             "--transition-duration", "1.5", "--transition-fps", "60", path]
        applyProc.running = true
    }

    function applyWallpaper(path) {
        if (path === "") return
        if (root.applyingPath !== "") {
            root.pendingPath = path
            return
        }
        root.startApply(path)
    }

    function nextInQueue() {
        if (root.pendingPath !== "") {
            const p = root.pendingPath
            root.pendingPath = ""
            root.startApply(p)
        }
    }

    Process {
        id: applyProc
        command: ["true"]
        onExited: (code) => {
            if (code === 0) {
                root.currentWallpaper = root.applyingPath
                matugenProc.command = ["matugen", "image", "-m", "dark", "--source-color-index", "0", root.applyingPath]
                matugenProc.running = true
            } else {
                root.applyingPath = ""
                root.nextInQueue()
            }
        }
    }

    Process {
        id: matugenProc
        command: ["true"]
        onExited: (code) => {
            root.applyingPath = ""
            root.nextInQueue()
        }
    }


    Process {
        id: listProc
        command: ["find", root.wallDir, "-maxdepth", "3", "-type", "f",
                  "(", "-iname", "*.png", "-o", "-iname", "*.jpg",
                  "-o", "-iname", "*.jpeg", "-o", "-iname", "*.webp",
                  "-o", "-iname", "*.gif", ")", "-print0"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.split("\0")
                const arr = []
                for (const p of parts) {
                    if (p.trim() !== "") arr.push(p)
                }
                root.wallpapers = arr
            }
        }
    }

    Process {
        id: currentProc
        command: ["awww", "query"]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = this.text.match(/currently displaying: image:\s*(\S+)/)
                if (m && m[1]) root.currentWallpaper = m[1]
            }
        }
    }

    function reload() {
        listProc.running = true
        currentProc.running = true
    }

    onVisibleChanged: {
        if (root.visible) root.reload()
    }

    Component.onCompleted: {
        if (root.visible) root.reload()
    }
}
