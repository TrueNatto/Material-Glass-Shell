import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import "./components"
import "./tabs"

ShellRoot {
    id: root

    property Theme theme: Theme {}

    readonly property var tabs: [
        { icon: "\uf00a", label: "Overview" },
        { icon: "\uf1c5", label: "Wallpapers" },
        { icon: "\uf118", label: "Emoji" },
        { icon: "\uf040", label: "Sketch" }
    ]
    property int activeTab: 0

    property var kbFocus: WlrKeyboardFocus.OnDemand

    property bool initialLoading: true

    onActiveTabChanged: {
        if (root.activeTab !== 2 && emojiTab.searchFocused) {
            emojiTab.releaseSearch()
        }
        if (root.activeTab === 1) {
            wallpapersTab.reload()
        }
    }

    PanelWindow {
        id: win
        color: "transparent"
        WlrLayershell.namespace: "quickshell:clock"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.kbFocus
        anchors.top: true
        anchors.left: true
        anchors.right: true
        readonly property real panelWidth: 730
        readonly property int screenW: WlrLayershell.screen ? WlrLayershell.screen.width : 1920
        margins.top: 55
        margins.left: Math.max(0, (win.screenW - win.panelWidth) / 2)
        margins.right: Math.max(0, (win.screenW - win.panelWidth) / 2)
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: 440
        implicitHeight: contentLayout.implicitHeight + 40

        onVisibleChanged: {
            if (win.visible) {
                root.initialLoading = true
                loadingHideTimer.restart()
            }
        }

        Rectangle {
            id: panel
            anchors.fill: parent
            radius: 14
            color: root.theme.surface
            border.width: 1
            border.color: root.theme.outline

            Column {
                id: contentLayout
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14
                visible: !root.initialLoading

                Rectangle {
                    z: 100
                    width: parent.width
                    height: 48
                    radius: 12
                    color: root.theme.surfaceContainer
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.05)

                    TabBar {
                        id: tabBar
                        anchors.fill: parent
                        tabs: root.tabs
                        activeTab: root.activeTab
                        theme: root.theme
                        onTabClicked: root.activeTab = index
                    }
                }

                Item {
                    id: viewport
                    width: parent.width
                    height: 372
                    clip: true

                    Item {
                        id: track
                        width: viewport.width * root.tabs.length
                        height: viewport.height

                        x: -root.activeTab * viewport.width
                        Behavior on x {
                            SpringAnimation {
                                spring: 2.4
                                damping: 0.35
                                epsilon: 0.001
                            }
                        }

                        Item {
                            width: viewport.width
                            height: viewport.height
                            x: 0
                            OverviewTab {
                                anchors.fill: parent
                                theme: root.theme
                                active: root.activeTab === 0
                            }
                        }
                        Item {
                            width: viewport.width
                            height: viewport.height
                            x: 1 * viewport.width
                            WallpapersTab {
                                id: wallpapersTab
                                anchors.fill: parent
                                theme: root.theme
                            }
                        }
                        Item {
                            width: viewport.width
                            height: viewport.height
                            x: 2 * viewport.width
                            EmojiTab {
                                id: emojiTab
                                anchors.fill: parent
                                theme: root.theme
                                active: root.activeTab === 2
                            }
                        }
                        Item {
                            width: viewport.width
                            height: viewport.height
                            x: 3 * viewport.width
                            SketchTab {
                                anchors.fill: parent
                                theme: root.theme
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: loadingOverlay
                anchors.fill: parent
                radius: panel.radius
                color: root.theme.outline
                visible: root.initialLoading

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressed: {}
                    onClicked: {}
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        id: spinner
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "\uf1ce"
                        color: root.theme.primary
                        font.family: root.theme.iconFont
                        font.pixelSize: 30
                        RotationAnimator {
                            target: spinner
                            from: 0
                            to: 360
                            duration: 700
                            loops: Animation.Infinite
                            running: loadingOverlay.visible
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Loading...."
                        color: "white"
                        font.family: root.theme.uiFont
                        font.weight: Font.Black
                        font.pixelSize: 13
                    }
                }
            }
        }
    }

    Timer {
        id: loadingHideTimer
        interval: 450
        repeat: false
        onTriggered: root.initialLoading = false
    }
}
