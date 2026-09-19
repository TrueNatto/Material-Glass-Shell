import QtQuick

Item {
    id: root

    required property string icon
    required property Theme theme
    property color iconColor: root.theme.fg
    property color activeColor: root.theme.primary
    property color activeBg: Qt.rgba(root.theme.primary.r, root.theme.primary.g, root.theme.primary.b, 0.15)
    property color hoverBg: Qt.alpha(root.theme.fg, 0.07)
    property bool active: false
    property bool enabled: true
    signal clicked()

    width: 32
    height: 32
    opacity: enabled ? 1 : 0.35
    Behavior on opacity { NumberAnimation { duration: 120 } }

    Rectangle {
        anchors.fill: parent
        radius: 9
        color: root.active ? root.activeBg : (hover.hovered ? root.hoverBg : "transparent")
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.active ? root.activeColor : root.iconColor
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        onClicked: root.clicked()
    }
}