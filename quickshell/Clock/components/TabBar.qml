import QtQuick

Item {
    id: root

    property var tabs: []
    property int activeTab: 0
    signal tabClicked(int index)

    required property Theme theme

    implicitHeight: 48

    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: root.tabs

            delegate: Item {
                required property var modelData
                required property int index
                property bool isActive: root.activeTab === index

                width: root.tabs.length > 0 ? parent.width / root.tabs.length : 0
                height: 48

                // ---- icon + label ----
                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.icon
                        font.family: theme.iconFont
                        font.pixelSize: 16
                        color: isActive ? theme.primary : theme.fgMuted
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label
                        font.family: theme.uiFont
                        font.weight: Font.Black
                        font.pixelSize: 13
                        color: isActive ? theme.fg : theme.fgMuted
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.tabClicked(index)
                }
            }
        }
    }

    Rectangle {
        id: slide
        readonly property real tabW: root.width / (root.tabs.length || 1)
        x: root.activeTab * tabW + 8
        y: (root.height - 36) / 2
        width: tabW - 16
        height: 36
        radius: 18

        color: Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.16)
        border.width: 1
        border.color: Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.35)

        Behavior on x { SpringAnimation { spring: 2.4; damping: 0.35; epsilon: 0.001 } }
    }
}