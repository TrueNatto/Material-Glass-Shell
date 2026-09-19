import QtQuick
Item {
    id: root
    required property Theme theme
    required property string icon
    required property string label
    property string status: ""
    property bool active: false
    property bool compact: false
    property bool customStatusColor: false
    property color statusColorOverride: "transparent"
    signal clicked()
    implicitWidth: 170
    implicitHeight: root.compact ? 50 : 66
    transformOrigin: Item.Center
    function pulse() {
        pulseAnim.restart()
    }
    readonly property color textColor: root.active ? root.theme.pillFg : root.theme.fg
    readonly property color statusColor: root.customStatusColor
        ? root.statusColorOverride
        : (root.active ? Qt.alpha(root.theme.pillFg, 0.78) : root.theme.fgMuted)
    Rectangle {
        anchors.fill: parent
        radius: root.compact ? 12 : 16
        color: root.active ? root.theme.primary : (m.hovered ? Qt.lighter(root.theme.surfaceContainer, 1.08) : root.theme.surfaceContainer)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.05)
        Behavior on color { ColorAnimation { duration: 130 } }
    }
    Row {
        anchors.fill: parent
        anchors.margins: 10
        visible: !root.compact
        spacing: 12
        Rectangle {
            width: 46
            height: 46
            radius: width / 2
            color: root.active ? Qt.rgba(0, 0, 0, 0.14) : root.theme.surfaceContainerHigh
            Text {
                anchors.centerIn: parent
                text: root.icon
                color: root.textColor
                font.family: root.theme.iconFont
                font.pixelSize: 20
            }
        }
        Column {
            width: parent.width - 46 - parent.spacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3
            Text {
                width: parent.width
                text: root.label
                elide: Text.ElideRight
                color: root.textColor
                font.family: root.theme.uiFont
                font.weight: Font.Black
                font.pixelSize: 16
            }
            Text {
                width: parent.width
                text: root.status
                elide: Text.ElideRight
                color: root.statusColor
                font.family: root.theme.uiFont
                font.weight: Font.Medium
                font.pixelSize: 13
            }
        }
    }
    Row {
        anchors.centerIn: parent
        visible: root.compact
        spacing: 12
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.textColor
            font.family: root.theme.iconFont
            font.pixelSize: 22
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.textColor
            font.family: root.theme.uiFont
            font.weight: Font.Black
            font.pixelSize: 16
        }
    }
    MouseArea {
        id: m
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            root.clicked()
            root.pulse()
        }
    }
    SequentialAnimation {
        id: pulseAnim
        running: false
        NumberAnimation {
            target: root
            property: "scale"
            to: 0.95
            duration: 90
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: root
            property: "scale"
            to: 1
            duration: 220
            easing.type: Easing.OutCubic
        }
    }
}
