import Quickshell.Io
import QtQuick
import "../components"

Item {
    id: root

    required property Theme theme

    // ---- clock state ----
    property int clkHour: 0
    property int clkMin: 0
    property string clkDate: ""

    // ---- system stats state (updated by processes below) ----
    property int cpuPercent: 0
    property int ramPercent: 0
    property int diskPercent: 0
    property int cpuLastTotal: 0
    property int cpuLastIdle: 0

    property bool active: false

    function pad(n) { return n < 10 ? "0" + n : "" + n }

    component StatBar: Item {
        id: bar
        required property string icon
        required property int pct

        property real displayPct: 0
        onPctChanged: bar.displayPct = bar.pct

        width: 38
        height: 210

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 5
            text: bar.icon
            color: root.theme.fgMuted
            font.family: root.theme.iconFont
            font.pixelSize: 15
        }

        Item {
            width: 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 33
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 22

            WaveCanvas {
                anchors.fill: parent
                fraction: bar.displayPct / 100
                color: Qt.rgba(root.theme.primary.r * 0.7, root.theme.primary.g * 0.7, root.theme.primary.b * 0.7, root.theme.primary.a)
                trackBg: root.theme.surfaceContainerHigh
                amplitude: 2.4
                wavelength: 18
                effectOpacity: 1
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -5
            text: bar.pct + "%"
            color: root.theme.fgMuted
            font.family: root.theme.uiFont
            font.weight: Font.Black
            font.pixelSize: 11
        }
    }

    readonly property real gap: 14
    readonly property real topH: 128
    readonly property real leftW: width * 0.27
    readonly property real rightW: width * 0.20
    readonly property real centerW: width - leftW - rightW - gap * 2

    Item {
        anchors.fill: parent

        // ============ LEFT: giant clock card ============
        Rectangle {
            x: 0
            y: 0
            width: root.leftW
            height: parent.height
            radius: 22
            color: theme.surfaceContainer
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.05)

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 36
                spacing: 8

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: root.pad(root.clkHour)
                    font.family: theme.uiFont
                    font.weight: Font.Black
                    font.pixelSize: 110
                    color: theme.primary
                }

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: root.pad(root.clkMin)
                    font.family: theme.uiFont
                    font.weight: Font.Black
                    font.pixelSize: 110
                    color: theme.primary
                }
            }

            // ---- date ----
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                width: parent.width - 8
                horizontalAlignment: Text.AlignHCenter
                text: root.clkDate
                font.family: theme.uiFont
                font.weight: Font.Black
                font.pixelSize: 16
                color: theme.fgMuted
            }
        }

        Rectangle {
            x: parent.width - root.rightW
            y: root.topH + root.gap
            width: root.rightW
            height: parent.height - root.topH - root.gap
            radius: 22
            color: theme.surfaceContainer
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.05)

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                spacing: 6

                StatBar {
                    icon: "\uf2db"
                    pct: root.cpuPercent
                }

                StatBar {
                    icon: "\uefc5"
                    pct: root.ramPercent
                }

                StatBar {
                    icon: "\uf0a0"
                    pct: root.diskPercent
                }
            }
        }

        Rectangle {
            x: root.leftW + root.gap
            y: root.topH + root.gap
            width: root.centerW
            height: parent.height - root.topH - root.gap
            radius: 22
            color: theme.surfaceContainer
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.05)

            CalendarCard {
                anchors.fill: parent
                anchors.margins: 14
                theme: root.theme
            }
        }

        // ============ TOP: system info card (neofetch) ============
        SystemInfoCard {
            x: root.leftW + root.gap
            y: 0
            width: parent.width - root.leftW - root.gap
            height: root.topH
            theme: root.theme
        }
    }

    function updateClock() {
        const d = new Date()
        root.clkHour = d.getHours()
        root.clkMin = d.getMinutes()
        const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        root.clkDate = months[d.getMonth()] + " " + d.getDate()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.updateClock()
    }



    FileView {
        id: statView
        path: "/proc/stat"
        onLoaded: {
            const parts = statView.text().split("\n")[0].trim().split(/\s+/)
            if (parts.length < 8) return
            const idle = parseInt(parts[4])
            let total = 0
            for (let i = 1; i < parts.length; i++) total += parseInt(parts[i])
            if (root.cpuLastTotal > 0) {
                const dTotal = total - root.cpuLastTotal
                const dIdle = idle - root.cpuLastIdle
                root.cpuPercent = dTotal > 0 ? Math.max(0, Math.min(100, Math.round(100 * (1 - dIdle / dTotal)))) : 0
            }
            root.cpuLastTotal = total
            root.cpuLastIdle = idle
        }
    }

    FileView {
        id: memView
        path: "/proc/meminfo"
        onLoaded: {
            const text = memView.text()
            const total = parseInt(text.match(/MemTotal:\s+(\d+)/)?.[1] || "0")
            const avail = parseInt(text.match(/MemAvailable:\s+(\d+)/)?.[1] || "0")
            root.ramPercent = total > 0 ? Math.max(0, Math.min(100, Math.round(100 * (total - avail) / total))) : 0
        }
    }

    Process {
        id: diskProc
        command: ["sh", "-c", "df -P / | tail -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(/\s+/)
                if (parts.length < 5) return
                const total = parseInt(parts[1])
                const used = parseInt(parts[2])
                root.diskPercent = total > 0 ? Math.max(0, Math.min(100, Math.round(100 * used / total))) : 0
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            statView.reload()
            memView.reload()
        }
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        onTriggered: diskProc.running = true
    }

    Component.onCompleted: {
        root.updateClock()
        diskProc.running = true
        cpuWarmup.start()
    }

    Timer {
        id: cpuWarmup
        interval: 300
        running: false
        repeat: false
        onTriggered: statView.reload()
    }
}