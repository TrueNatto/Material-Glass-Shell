import QtQml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../components"
Item {
    id: root
    required property Theme theme
    property real brushSize: 5
    property bool eraseMode: false
    property color brushColor: theme.primary
    property bool colorPickerOpen: false
    property point colorBtnPos: Qt.point(0, 0)
    property var swatchColors: [
        theme.primary.toString(),
        "#E57373", "#FFB74D", "#FFF176",
        "#81C784", "#64B5F6", "#BA68C8", "#F06292",
        "#FFFFFF", "#000000"
    ]
    onColorPickerOpenChanged: {
        if (root.colorPickerOpen) {
            root.colorBtnPos = colorBtn.mapToItem(root, 0, 0)
        }
    }
    property bool bgPainted: false
    property bool sketchReady: false
    property real lastX: 0
    property real lastY: 0
    function canvasColor() {
        return root.eraseMode ? theme.surfaceContainerHigh : root.brushColor
    }
    function colorString(c) {
        return c.toString()
    }
    function clearBuffer() {
        const ctx = sketchCanvas.getContext("2d")
        ctx.fillStyle = theme.surfaceContainerHigh.toString()
        ctx.fillRect(0, 0, sketchCanvas.width, sketchCanvas.height)
        sketchCanvas.requestPaint()
    }
    SequentialAnimation {
        id: clearAnim
        running: false
        NumberAnimation {
            target: sketchCanvas
            property: "opacity"
            to: 0
            duration: 150
            easing.type: Easing.InQuad
        }
        ScriptAction {
            script: root.clearBuffer()
        }
        NumberAnimation {
            target: sketchCanvas
            property: "opacity"
            to: 1
            duration: 150
            easing.type: Easing.OutQuad
        }
    }
    property bool toastVisible: false
    property string toastText: ""
    Timer {
        id: toastTimer
        interval: 900
        repeat: false
        onTriggered: root.toastVisible = false
    }
    function showToast(msg) {
        root.toastText = msg
        root.toastVisible = true
        toastTimer.restart()
    }
    function copySketch() {
        const grab = sketchCanvas.grabToImage(function(result) {
            const tmp = "/tmp/quickshell-sketch.png"
            if (!result.saveToFile(tmp)) {
                console.log("SketchTab: grabToImage failed")
                return
            }
            copyProc.command = ["sh", "-c", "wl-copy < " + tmp]
            copyProc.running = true
            root.showToast("Copied!")
        })
        if (!grab) console.log("SketchTab: grabToImage not supported")
    }
    readonly property string sketchDir: Quickshell.env("HOME") + "/Pictures/Sketch"
    function saveSketch() {
        const ts = new Date()
        const pad = n => n < 10 ? "0" + n : "" + n
        const name = "sketch-" + ts.getFullYear() + pad(ts.getMonth() + 1) + pad(ts.getDate())
                   + "-" + pad(ts.getHours()) + pad(ts.getMinutes()) + pad(ts.getSeconds()) + ".png"
        const target = root.sketchDir + "/" + name
        const grab = sketchCanvas.grabToImage(function(result) {
            if (!result.saveToFile(target)) {
                console.log("SketchTab: save failed")
                return
            }
            root.showToast("Saved in ~/Pictures/Sketch/")
        })
        if (!grab) console.log("SketchTab: grabToImage not supported")
    }
    Process {
        id: copyProc
        command: ["true"]
    }
    Process {
        id: mkdirProc
        command: ["mkdir", "-p", root.sketchDir]
        onExited: if (code === 0) root.sketchReady = root.sketchReady
    }
    Column {
        anchors.fill: parent
        spacing: 12
        Rectangle {
            id: colorToolbar
            width: parent.width
            height: 40
            radius: 12
            color: theme.surfaceContainer
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.05)
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10
                Text {
                    text: "\uf040"
                    color: theme.primary
                    font.family: theme.iconFont
                    font.pixelSize: 15
                }
                Text {
                    text: "Size"
                    color: theme.fgMuted
                    font.family: theme.uiFont
                    font.weight: Font.Black
                    font.pixelSize: 11
                }
                Item {
                    id: sizeSlider
                    Layout.fillWidth: true
                    Layout.preferredWidth: 120
                    Layout.maximumWidth: 160
                    Layout.alignment: Qt.AlignVCenter
                    implicitHeight: 24
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 4
                        radius: 2
                        color: theme.surfaceContainerHigh
                        Rectangle {
                            width: parent.width * ((root.brushSize - 1) / 34)
                            height: 4
                            radius: 2
                            color: theme.primary
                        }
                    }
                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        color: theme.primary
                        border.width: 2
                        border.color: theme.pillFg
                        x: (parent.width - width) * ((root.brushSize - 1) / 34)
                        y: (parent.height - height) / 2
                    }
                    MouseArea {
                        id: sliderArea
                        anchors.fill: parent
                        function updateFromX(mx) {
                            const frac = Math.max(0, Math.min(1, mx / sliderArea.width))
                            root.brushSize = 1 + Math.round(frac * 34)
                        }
                        onPressed: (mouse) => sliderArea.updateFromX(mouse.x)
                        onPositionChanged: (mouse) => {
                            if (pressed) sliderArea.updateFromX(mouse.x)
                        }
                    }
                }
                Text {
                    text: Math.round(root.brushSize) + "px"
                    color: theme.fgMuted
                    font.family: theme.uiFont
                    font.weight: Font.Medium
                    font.pixelSize: 11
                }
                Rectangle {
                    id: colorBtn
                    width: 26
                    height: 26
                    radius: 13
                    color: root.brushColor
                    border.width: 2
                    border.color: root.colorPickerOpen ? theme.primary : Qt.rgba(1, 1, 1, 0.15)
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: theme.primary
                        opacity: colorArea.hovered ? 0.18 : 0
                        Behavior on opacity { NumberAnimation { duration: 120 } }
                    }
                    MouseArea {
                        id: colorArea
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: () => root.colorPickerOpen = !root.colorPickerOpen
                    }
                }
                Rectangle {
                    id: brushBtn
                    width: brushIcon.implicitWidth + brushLabel.implicitWidth + 26
                    height: 26
                    radius: 13
                    color: !root.eraseMode ? theme.primary : theme.surfaceContainerHigh
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: theme.primary
                        opacity: brushArea.hovered ? 0.18 : 0
                        Behavior on opacity { NumberAnimation { duration: 120 } }
                    }
                    Text {
                        id: brushIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uf1fc"
                        color: !root.eraseMode ? theme.pillFg : theme.fg
                        font.family: theme.iconFont
                        font.pixelSize: 13
                    }
                    Text {
                        id: brushLabel
                        anchors.left: brushIcon.right
                        anchors.leftMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Brush"
                        color: !root.eraseMode ? theme.pillFg : theme.fg
                        font.family: theme.uiFont
                        font.weight: Font.Black
                        font.pixelSize: 11
                    }
                    MouseArea {
                        id: brushArea
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: () => {
                            root.eraseMode = false
                        }
                    }
                }
                Rectangle {
                    id: eraseBtn
                    width: eraseIcon.implicitWidth + eraseLabel.implicitWidth + 26
                    height: 26
                    radius: 13
                    color: root.eraseMode ? theme.primary : theme.surfaceContainerHigh
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: theme.primary
                        opacity: eraseArea.hovered ? 0.18 : 0
                        Behavior on opacity { NumberAnimation { duration: 120 } }
                    }
                    Text {
                        id: eraseIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uf12d"
                        color: root.eraseMode ? theme.pillFg : theme.fg
                        font.family: theme.iconFont
                        font.pixelSize: 13
                    }
                    Text {
                        id: eraseLabel
                        anchors.left: eraseIcon.right
                        anchors.leftMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Erase"
                        color: root.eraseMode ? theme.pillFg : theme.fg
                        font.family: theme.uiFont
                        font.weight: Font.Black
                        font.pixelSize: 11
                    }
                    MouseArea {
                        id: eraseArea
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: () => {
                            root.eraseMode = !root.eraseMode
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 8
                }
                Rectangle {
                    id: copyBtn
                    width: copyIcon.implicitWidth + copyLabel.implicitWidth + 26
                    height: 26
                    radius: 13
                    color: theme.surfaceContainerHigh
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: theme.primary
                        opacity: copyArea.hovered ? 0.18 : 0
                        Behavior on opacity { NumberAnimation { duration: 120 } }
                    }
                    Text {
                        id: copyIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uf0c5"
                        color: theme.fg
                        font.family: theme.iconFont
                        font.pixelSize: 13
                    }
                    Text {
                        id: copyLabel
                        anchors.left: copyIcon.right
                        anchors.leftMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Copy"
                        color: theme.fg
                        font.family: theme.uiFont
                        font.weight: Font.Black
                        font.pixelSize: 11
                    }
                    MouseArea {
                        id: copyArea
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: () => root.copySketch()
                    }
                }
                Rectangle {
                    id: saveBtn
                    width: saveIcon.implicitWidth + saveLabel.implicitWidth + 26
                    height: 26
                    radius: 13
                    color: theme.surfaceContainerHigh
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: theme.primary
                        opacity: saveArea.hovered ? 0.18 : 0
                        Behavior on opacity { NumberAnimation { duration: 120 } }
                    }
                    Text {
                        id: saveIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uf0c7"
                        color: theme.fg
                        font.family: theme.iconFont
                        font.pixelSize: 13
                    }
                    Text {
                        id: saveLabel
                        anchors.left: saveIcon.right
                        anchors.leftMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Save"
                        color: theme.fg
                        font.family: theme.uiFont
                        font.weight: Font.Black
                        font.pixelSize: 11
                    }
                    MouseArea {
                        id: saveArea
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: () => root.saveSketch()
                    }
                }
                Rectangle {
                    id: clearBtn
                    width: clearIcon.implicitWidth + clearLabel.implicitWidth + 26
                    height: 26
                    radius: 13
                    color: theme.surfaceContainerHigh
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: theme.primary
                        opacity: clearArea.hovered ? 0.18 : 0
                        Behavior on opacity { NumberAnimation { duration: 120 } }
                    }
                    Text {
                        id: clearIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uede4"
                        color: theme.fg
                        font.family: theme.iconFont
                        font.pixelSize: 13
                    }
                    Text {
                        id: clearLabel
                        anchors.left: clearIcon.right
                        anchors.leftMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Clear"
                        color: theme.fg
                        font.family: theme.uiFont
                        font.weight: Font.Black
                        font.pixelSize: 11
                    }
                    MouseArea {
                        id: clearArea
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: () => {
                            clearAnim.restart()
                        }
                    }
                }
            }
        }
        Rectangle {
            width: parent.width
            height: parent.height - 40 - parent.spacing
            radius: 12
            clip: true
            color: theme.surfaceContainerHigh
            Canvas {
                id: sketchCanvas
                anchors.fill: parent
                anchors.margins: 1
                antialiasing: true
                renderTarget: Canvas.Image
                renderStrategy: Canvas.Cooperative
                onPaint: {
                    const ctx = getContext("2d")
                    if (!root.bgPainted) {
                        ctx.fillStyle = theme.surfaceContainerHigh.toString()
                        ctx.fillRect(0, 0, width, height)
                        root.bgPainted = true
                    }
                    root.sketchReady = true
                }
            }
            MouseArea {
                id: drawArea
                anchors.fill: parent
                anchors.margins: 1
                enabled: root.sketchReady
                onPressed: (mouse) => {
                    root.lastX = mouse.x
                    root.lastY = mouse.y
                    const ctx = sketchCanvas.getContext("2d")
                    ctx.fillStyle = root.colorString(root.canvasColor())
                    ctx.beginPath()
                    ctx.arc(mouse.x, mouse.y, Math.max(1, root.brushSize / 2), 0, Math.PI * 2)
                    ctx.closePath()
                    ctx.fill()
                    sketchCanvas.requestPaint()
                }
                onPositionChanged: (mouse) => {
                    if (!pressed) return
                    const ctx = sketchCanvas.getContext("2d")
                    ctx.lineWidth = root.brushSize
                    ctx.strokeStyle = root.colorString(root.canvasColor())
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"
                    ctx.beginPath()
                    ctx.moveTo(root.lastX, root.lastY)
                    ctx.lineTo(mouse.x, mouse.y)
                    ctx.stroke()
                    root.lastX = mouse.x
                    root.lastY = mouse.y
                    sketchCanvas.requestPaint()
                }
            }
        }
    }
    Rectangle {
        visible: root.toastVisible
        z: 60
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 52
        width: toastTextItem.implicitWidth + 24
        height: toastTextItem.implicitHeight + 12
        radius: 10
        color: theme.surfaceContainerHigh
        border.width: 1
        border.color: theme.primary
        opacity: root.toastVisible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
        Text {
            id: toastTextItem
            anchors.centerIn: parent
            text: root.toastText
            color: theme.fg
            font.family: theme.uiFont
            font.weight: Font.Black
            font.pixelSize: 12
        }
    }
    Rectangle {
        visible: root.colorPickerOpen
        z: 50
        width: 5 * 22 + 4 * 4 + 16
        height: 2 * 22 + 4 + 16
        radius: 10
        color: theme.surfaceContainerHigh
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.05)
        x: root.colorBtnPos.x + 13 - width / 2
        y: root.colorBtnPos.y + 26 + 8
        Grid {
            anchors.fill: parent
            anchors.margins: 8
            columns: 5
            spacing: 4
            Repeater {
                model: root.swatchColors
                delegate: Rectangle {
                    width: 22
                    height: 22
                    radius: 4
                    color: modelData
                    border.width: modelData === root.brushColor ? 2 : 1
                    border.color: modelData === root.brushColor
                        ? theme.primary
                        : Qt.rgba(1, 1, 1, 0.1)
                    MouseArea {
                        anchors.fill: parent
                        onClicked: () => {
                            root.brushColor = modelData
                            root.colorPickerOpen = false
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: mkdirProc.running = true
}
