import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "components"
ShellRoot {
    id: root
    property Theme theme: Theme {}
    readonly property string home: Quickshell.env("HOME")
    readonly property real panelW: 420
    readonly property real panelH: 480
    readonly property real m: 18
    readonly property real gap: 14
    readonly property real tileGap: 10
    readonly property real hHeader: 0.08 * panelH
    readonly property real hTile: 0.150 * panelH
    readonly property real gridH: 3 * hTile + 2 * tileGap
    readonly property real hPills: panelH - 2 * m - hHeader - gridH - 3 * gap
    readonly property real pillGap: 0.04 * panelW
    readonly property real pillShift: 20
    readonly property real pillW: 0.5 * pillH
    readonly property real pillH: hPills
    readonly property real pillTopR: 0.5 * pillW
    readonly property real pillBottomR: Math.min(pillW, pillH) / 2
    property var tiles: [
        { kind: "wifi",   icon: "󰤨", label: "Wi-Fi" },
        { kind: "vol",    icon: "", label: "Volume" },
        { kind: "bt",     icon: "", label: "Bluetooth" },
        { kind: "pow",    icon: "", label: "Power Mode" },
        { kind: "dnd",    icon: "", label: "Don't Disturb" },
        { kind: "notify", icon: "", label: "Notify" },
        { kind: "clip",   icon: "", label: "Clipboard" },
        { kind: "app",    icon: "", label: "Apps" }
    ]
    property bool wifiOn: false
    property string wifiName: ""
    property bool btOn: false
    property int volPct: 0
    property bool volMuted: false
    property bool dnd: false
    property string governor: "unknown"
    property int brightness: 0
    property real volShown: 0
    property real briShown: 0
    function clamp01(v) { return Math.max(0, Math.min(1, v)) }
    function tileIcon(kind) {
        switch (kind) {
            case "wifi": return root.wifiOn ? "󰖩" : "󰖪"
            case "bt": return root.btOn ? "󰂯" : "󰂲"
            case "vol": return root.volMuted || root.volPct <= 0 ? "" : root.volPct < 40 ? "" : ""
        }
        return root.tiles.find(t => t.kind === kind).icon
    }
    function tileStatus(kind) {
        switch (kind) {
            case "wifi": return root.wifiOn ? (root.wifiName !== "" ? root.wifiName : "On") : "Off"
            case "bt": return root.btOn ? "On" : "Off"
            case "vol": return root.volMuted ? "Muted" : root.volPct + "%"
            case "dnd": return root.dnd ? "On" : "Off"
            case "pow": return root.governor.charAt(0).toUpperCase() + root.governor.slice(1)
            case "notify": return "History"
        }
        return ""
    }
    function tileActive(kind) {
        switch (kind) {
            case "wifi": return root.wifiOn
            case "bt": return root.btOn
            case "dnd": return root.dnd
        }
        return false
    }
    function tileStatusColor(kind) {
        if (kind === "pow") {
            if (root.governor === "performance") return root.theme.powPerf
            if (root.governor === "powersave") return root.theme.powSave
        }
        return "transparent"
    }
    Process {
        id: launcher
        command: ["true"]
    }
    function run(cmd) {
        launcher.command = cmd
        launcher.running = true
    }
    function tileClicked(kind) {
        switch (kind) {
            case "wifi": root.run(["networkmanager_dmenu"]); break
            case "bt": root.run(["rofi-bluetooth"]); break
            case "vol": root.run(["rofi-sink"]); break
            case "dnd": root.toggleDnd(); break
            case "pow": root.cycleGovernor(); break
            case "notify": root.run(["rofi-notify"]); break
            case "clip": root.run(["rofi-clipboard"]); break
            case "app": root.run(["rofi", "-show", "drun", "-show-icons"]); break
        }
    }
    Process { id: dndCmd; command: ["true"] }
    function toggleDnd() {
        dndCmd.command = root.dnd
            ? ["makoctl", "mode", "-r", "do-not-disturb"]
            : ["makoctl", "mode", "-a", "do-not-disturb"]
        root.dnd = !root.dnd
        dndCmd.running = true
    }
    property var governors: ["performance"]
    property int govIndex: 0
    onGovernorChanged: {
        const i = root.governors.indexOf(root.governor)
        if (i >= 0) root.govIndex = i
    }
    Process {
        id: govSetProc
        command: ["true"]
        onExited: (code) => { if (code !== 0) console.log("Center: cpupower frequency-set failed (sudo NOPASSWD?)") }
    }
    function cycleGovernor() {
        if (root.governors.length < 2) return
        root.govIndex = (root.govIndex + 1) % root.governors.length
        root.governor = root.governors[root.govIndex]
        govSetProc.command = ["sudo", "cpupower", "frequency-set", "-g", root.governors[root.govIndex]]
        govSetProc.running = true
    }
    Process { id: briSetProc; command: ["true"] }
    function setBrightness(f) {
        briSetProc.command = ["brightnessctl", "set", Math.round(f * 100) + "%"]
        briSetProc.running = true
    }
    Process { id: volSetProc; command: ["true"] }
    function setVolume(f) {
        volSetProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.round(f * 100) + "%"]
        volSetProc.running = true
    }
    Process {
        id: wifiOnProc
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector { onStreamFinished: root.wifiOn = this.text.trim() === "enabled" }
    }
    Process {
        id: wifiNameProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID", "dev", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                let ssid = ""
                for (const l of this.text.split("\n"))
                    if (l.startsWith("*")) { ssid = l.split(":").slice(1).join(":").replace(/\\:/g, ":").trim(); break }
                root.wifiName = ssid
            }
        }
    }
    Process {
        id: btProc
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector { onStreamFinished: root.btOn = this.text.includes("Powered: yes") }
    }
    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = this.text.match(/Volume:\s*([0-9.]+)/)
                root.volPct = m ? Math.round(parseFloat(m[1]) * 100) : 0
                root.volMuted = this.text.includes("MUTED")
                if (!volDrag.dragging) root.volShown = root.volPct / 100
            }
        }
    }
    Process {
        id: dndProc
        command: ["makoctl", "mode"]
        stdout: StdioCollector { onStreamFinished: root.dnd = this.text.includes("do-not-disturb") }
    }
    FileView {
        id: govFile
        path: "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
        onLoaded: root.governor = govFile.text().trim()
        onLoadFailed: (error) => console.log("Center: cannot read scaling_governor: " + error)
    }
    FileView {
        id: govAvail
        path: "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors"
        onLoaded: {
            const list = govAvail.text().trim().split(/\s+/).filter(s => s !== "")
            if (list.length > 0) root.governors = list
        }
        onLoadFailed: (error) => console.log("Center: cannot read scaling_available_governors: " + error)
    }
    Process {
        id: briProc
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = this.text.trim().split(",")
                root.brightness = p.length >= 4 ? parseInt(p[3]) : 0
                if (!briDrag.dragging) root.briShown = root.brightness / 100
            }
        }
    }
    Timer {
        interval: 25
        running: true
        repeat: true
        onTriggered: root.pollFast()
    }
    Timer {
        interval: 350
        running: true
        repeat: true
        onTriggered: root.pollSlow()
    }
    function pollFast() {
        volProc.running = true
        briProc.running = true
    }
    function pollSlow() {
        wifiOnProc.running = true
        wifiNameProc.running = true
        btProc.running = true
        dndProc.running = true
        govFile.reload()
        govAvail.reload()
    }
    Component.onCompleted: {
        root.pollFast()
        root.pollSlow()
    }
    PanelWindow {
        color: "transparent"
        WlrLayershell.namespace: "quickshell:center"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        anchors.top: true
        anchors.right: true
        margins.top: 55
        margins.right: 14
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: root.panelW
        implicitHeight: root.panelH
        Rectangle {
            anchors.fill: parent
            radius: 20
            color: root.theme.surface
            border.width: 1
            border.color: root.theme.outline
            Column {
                id: content
                anchors.fill: parent
                anchors.margins: root.m
                spacing: root.gap
                Item {
                    width: parent.width
                    height: root.hHeader
                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Center"
                        color: root.theme.fg
                        font.family: root.theme.uiFont
                        font.weight: Font.Black
                        font.pixelSize: 21
                    }
                }
                Grid {
                    id: grid
                    width: parent.width
                    height: root.gridH
                    columns: 2
                    spacing: root.tileGap
                    Repeater {
                        model: root.tiles.slice(0, 6)
                        delegate: QuickTile {
                            required property var modelData
                            width: (parent.width - parent.spacing) / 2
                            height: (grid.height - grid.spacing * 2) / 3
                            icon: root.tileIcon(modelData.kind)
                            label: modelData.label
                            status: root.tileStatus(modelData.kind)
                            active: root.tileActive(modelData.kind)
                            customStatusColor: modelData.kind === "pow" && (root.governor === "performance" || root.governor === "powersave")
                            statusColorOverride: root.tileStatusColor(modelData.kind)
                            theme: root.theme
                            onClicked: root.tileClicked(modelData.kind)
                        }
                    }
                }
                Item {
                    width: parent.width
                    height: root.hPills
                    Rectangle {
                        width: root.pillShift + 2 * root.pillW + root.pillGap + 10
                        height: root.hPills + 20
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 10
                        radius: 16
                        color: root.theme.surfaceContainer
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.05)
                    }
                    OSDPill {
                        id: pillBri
                        width: root.pillW
                        height: root.pillH
                        anchors.left: parent.left
                        anchors.leftMargin: root.pillShift
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 10
                        kind: "brightness"
                        fraction: briDrag.dragging ? briDrag.frac : root.briShown
                        topRadius: root.pillTopR
                        bottomRadius: root.pillBottomR
                        accent: root.theme.primary
                        mutedColor: root.theme.fgMuted
                        trackBg: root.theme.surfaceContainer
                        chipBg: root.theme.surface
                        onChip: root.theme.fg
                        fontFamily: root.theme.uiFont
                        iconFont: root.theme.iconFont
                        MouseArea {
                            id: briDrag
                            anchors.fill: parent
                            property bool dragging: false
                            property real frac: 0
                            onPressed: mouse => {
                                briDrag.dragging = true
                                briDrag.frac = root.clamp01(1 - mouse.y / pillBri.height)
                                briDebounce.start()
                            }
                            onPositionChanged: mouse => {
                                if (briDrag.dragging) {
                                    briDrag.frac = root.clamp01(1 - mouse.y / pillBri.height)
                                    briDebounce.restart()
                                }
                            }
                            onReleased: {
                                briDrag.dragging = false
                                root.briShown = briDrag.frac
                                briDebounce.stop()
                                root.setBrightness(briDrag.frac)
                            }
                        }
                        Timer {
                            id: briDebounce
                            interval: 150
                            repeat: true
                            onTriggered: if (briDrag.dragging) root.setBrightness(briDrag.frac)
                        }
                    }
                    OSDPill {
                        id: pillVol
                        width: root.pillW
                        height: root.pillH
                        anchors.left: parent.left
                        anchors.leftMargin: root.pillW + root.pillGap + root.pillShift
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 10
                        kind: "volume"
                        fraction: volDrag.dragging ? volDrag.frac : root.volShown
                        muted: root.volMuted
                        topRadius: root.pillTopR
                        bottomRadius: root.pillBottomR
                        accent: root.theme.primary
                        mutedColor: root.theme.fgMuted
                        trackBg: root.theme.surfaceContainer
                        chipBg: root.theme.surface
                        onChip: root.theme.fg
                        fontFamily: root.theme.uiFont
                        iconFont: root.theme.iconFont
                        MouseArea {
                            id: volDrag
                            anchors.fill: parent
                            property bool dragging: false
                            property real frac: 0
                            onPressed: mouse => {
                                volDrag.dragging = true
                                volDrag.frac = root.clamp01(1 - mouse.y / pillVol.height)
                                volDebounce.start()
                            }
                            onPositionChanged: mouse => {
                                if (volDrag.dragging) {
                                    volDrag.frac = root.clamp01(1 - mouse.y / pillVol.height)
                                    volDebounce.restart()
                                }
                            }
                            onReleased: {
                                volDrag.dragging = false
                                root.volShown = volDrag.frac
                                volDebounce.stop()
                                root.setVolume(volDrag.frac)
                            }
                        }
                        Timer {
                            id: volDebounce
                            interval: 150
                            repeat: true
                            onTriggered: if (volDrag.dragging) root.setVolume(volDrag.frac)
                        }
                    }
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 10
                        width: 185
                        height: 145
                        radius: 16
                        color: root.theme.surfaceContainer
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.05)
                        Column {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: root.gap
                            Repeater {
                                model: root.tiles.slice(6, 8)
                                delegate: QuickTile {
                                    required property var modelData
                                    width: parent.width
                                    height: (parent.height - parent.spacing) / 2
                                    compact: true
                                    icon: modelData.icon
                                    label: modelData.label
                                    theme: root.theme
                                    onClicked: root.tileClicked(modelData.kind)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
