import QtQuick

Item {
    id: root

    required property Theme theme

    // ---- calendar state ----
    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth() // 0-based
    property var cellModel: []

    readonly property var weekStart: 1 // Monday

    function buildModel() {
        const y = root.viewYear
        const m = root.viewMonth
        const first = new Date(y, m, 1)
        const startOffset = ((first.getDay() + 7) - root.weekStart) % 7
        const daysInMonth = new Date(y, m + 1, 0).getDate()
        const now = new Date()
        const today = { y: now.getFullYear(), m: now.getMonth(), d: now.getDate() }
        const cells = []

        for (let i = 0; i < 42; i++) {
            const dayNum = i - startOffset + 1
            const inMonth = dayNum >= 1 && dayNum <= daysInMonth
            cells.push({
                label: inMonth ? dayNum : 0,
                inMonth: inMonth,
                isToday: inMonth && dayNum === today.d && m === today.m && y === today.y
            })
        }
        root.cellModel = cells
    }

    function prevMonth() {
        root.viewMonth -= 1
        if (root.viewMonth < 0) { root.viewMonth = 11; root.viewYear -= 1 }
        root.buildModel()
    }

    function nextMonth() {
        root.viewMonth = (root.viewMonth + 1) % 12
        if (root.viewMonth === 0) root.viewYear += 1
        root.buildModel()
    }

    readonly property string monthLabel: {
        const months = ["January","February","March","April","May","June","July","August","September","October","November","December"]
        return months[root.viewMonth] + " " + root.viewYear
    }

    readonly property var weekdayLabels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    Component.onCompleted: root.buildModel()

    component NavArrow: Rectangle {
        id: arrow
        required property string icon
        signal clicked()

        width: 24
        height: 24
        radius: 7
        color: hover.hovered ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            anchors.centerIn: parent
            text: arrow.icon
            color: root.theme.fgMuted
            font.family: root.theme.iconFont
            font.pixelSize: 11
        }

        MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: arrow.clicked()
        }
    }

    Column {
        anchors.fill: parent
        spacing: 4

        // ---- header: month + year | arrows ----
        Item {
            width: parent.width
            height: 26

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.monthLabel
                font.family: theme.uiFont
                font.weight: Font.Black
                font.pixelSize: 13
                color: theme.fg
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                NavArrow {
                    icon: "\uf053"
                    onClicked: root.prevMonth()
                }

                NavArrow {
                    icon: "\uf054"
                    onClicked: root.nextMonth()
                }
            }
        }

        // ---- weekday header ----
        Row {
            width: parent.width
            height: 18
            Repeater {
                model: root.weekdayLabels
                delegate: Text {
                    required property string modelData
                    width: parent.width / 7
                    height: parent.height
                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: theme.uiFont
                    font.weight: Font.Black
                    font.pixelSize: 11
                    color: theme.fgMuted
                }
            }
        }

        // ---- day grid (42 cells) ----
        Grid {
            width: parent.width
            height: parent.height - 26 - 18 - 8
            columns: 7
            rows: 6

            Repeater {
                model: root.cellModel
                delegate: Rectangle {
                    required property var modelData
                    width: parent.width / 7
                    height: parent.height / 6
                    radius: 8
                    color: modelData.isToday ? Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.45) : "transparent"
                    border.width: modelData.isToday ? 1 : 0
                    border.color: modelData.isToday ? Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.9) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.inMonth ? modelData.label : ""
                        font.family: theme.uiFont
                        font.weight: Font.Black
                        font.pixelSize: 12
                        color: modelData.isToday ? theme.fg : theme.fgMuted
                    }
                }
            }
        }
    }
}