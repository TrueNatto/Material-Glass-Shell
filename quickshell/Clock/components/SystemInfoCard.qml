import Quickshell
import Quickshell.Io
import QtQuick
Item {
    id: root
    required property Theme theme
    readonly property string avatarSavePath: Quickshell.env("HOME") + "/.cache/quickshell/clock-avatar-char.txt"
    property string avatarChar: "\uf31c"
    property bool editing: false
    readonly property string avatarFont: {
        const cp = root.avatarChar.codePointAt(0)
        return (cp >= 0xE000 && cp <= 0xF8FF) ? root.theme.iconFont : root.theme.uiFont
    }
    function firstGrapheme(s) {
        const cps = Array.from(String(s || ""))
        if (cps.length === 0) return ""
        let end = 1
        for (let i = 1; i < cps.length; i++) {
            const cp = cps[i].codePointAt(0)
            const prevCp = cps[i - 1].codePointAt(0)
            const isZwj = cps[i - 1] === "\u200D"
            const isVs = cp === 0xFE0F || cp === 0xFE0E
            const isSkin = cp >= 0x1F3FB && cp <= 0x1F3FF
            const isRegionalPrev = prevCp >= 0x1F1E6 && prevCp <= 0x1F1FF
            const isRegional = cp >= 0x1F1E6 && cp <= 0x1F1FF
            if (isZwj) { end = i + 1; continue }
            if (isVs) { end = i + 1; continue }
            if (isSkin) { end = i + 1; continue }
            if (isRegionalPrev && isRegional) { end = i + 1; continue }
            break
        }
        return cps.slice(0, end).join("")
    }
    function lastGrapheme(s) {
        const cps = Array.from(String(s || ""))
        if (cps.length === 0) return ""
        let start = 0
        for (let i = 1; i < cps.length; i++) {
            const cp = cps[i].codePointAt(0)
            const prevCp = cps[i - 1].codePointAt(0)
            const isZwj = cp === 0x200D
            const isZwjPrev = prevCp === 0x200D
            const isVs = cp === 0xFE0F || cp === 0xFE0E
            const isSkin = cp >= 0x1F3FB && cp <= 0x1F3FF
            const isCombining = cp >= 0x0300 && cp <= 0x036F
            const isRegionalPrev = prevCp >= 0x1F1E6 && prevCp <= 0x1F1FF
            const isRegional = cp >= 0x1F1E6 && cp <= 0x1F1FF
            if (isZwj || isZwjPrev || isVs || isSkin || isCombining
                    || (isRegionalPrev && isRegional)) continue
            start = i
        }
        return cps.slice(start).join("")
    }
    function startEdit() {
        root.editing = true
        avatarInput.text = ""
        avatarInput.forceActiveFocus()
    }
    function commitAvatar() {
        if (!root.editing) return
        const t = root.firstGrapheme(avatarInput.text)
        if (t !== "") {
            root.avatarChar = t
            saveAvatar.running = true
        }
        root.editing = false
        avatarInput.focus = false
    }
    property string sysUser: ""
    property string sysHost: ""
    property string sysUptime: ""
    Rectangle {
        anchors.fill: parent
        radius: 22
        color: theme.surfaceContainer
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.05)
        clip: true
        Row {
            anchors.fill: parent
            Item {
                width: 169
                height: parent.height
                Text {
                    id: avatarText
                    anchors.centerIn: parent
                    text: root.avatarChar
                    font.family: root.avatarFont
                    font.pixelSize: 80
                    color: theme.primary
                }
                TextInput {
                    id: avatarInput
                    anchors.centerIn: parent
                    width: 120
                    height: 100
                    text: ""
                    color: "transparent"
                    selectionColor: "transparent"
                    cursorVisible: false
                    font.family: root.avatarFont
                    font.pixelSize: 80
                    clip: true
                    onTextChanged: {
                        const g = root.lastGrapheme(avatarInput.text)
                        if (avatarInput.text !== g) avatarInput.text = g
                        root.avatarChar = g !== "" ? g : root.avatarChar
                    }
                    onAccepted: root.commitAvatar()
                    onActiveFocusChanged: if (!activeFocus && root.editing) root.commitAvatar()
                }
                Rectangle {
                    anchors.fill: avatarInput
                    radius: 16
                    color: "transparent"
                    border.width: root.editing ? 1 : 0
                    border.color: theme.primary
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: !root.editing
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.startEdit()
                }
            }
            Column {
                width: parent.width - 169 - 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 9
                InfoRow {
                    label: "User"
                    value: root.sysUser
                }
                InfoRow {
                    label: "Hostname"
                    value: root.sysHost
                }
                InfoRow {
                    label: "Uptime"
                    value: root.sysUptime
                }
            }
        }
    }
    component InfoRow: Row {
        id: row
        required property string label
        required property string value
        width: parent.width
        spacing: 10
        Text {
            id: lbl
            width: 84
            text: row.label + ":"
            color: theme.fgMuted
            font.family: theme.uiFont
            font.weight: Font.Black
            font.pixelSize: 14
            elide: Text.ElideRight
        }
        Text {
            text: row.value
            color: theme.fg
            font.family: theme.uiFont
            font.weight: Font.Black
            font.pixelSize: 14
            elide: Text.ElideRight
        }
    }
    Process {
        id: userProc
        command: ["whoami"]
        stdout: StdioCollector {
            onStreamFinished: root.sysUser = this.text.trim()
        }
    }
    Process {
        id: hostProc
        command: ["uname", "-n"]
        stdout: StdioCollector {
            onStreamFinished: root.sysHost = this.text.trim()
        }
    }
    Process {
        id: upProc
        command: ["uptime", "-p"]
        stdout: StdioCollector {
            onStreamFinished: {
                let t = this.text.trim()
                t = t.replace(/^up\s+/i, "")
                t = t.replace(/\s*minutes?/i, " mins")
                root.sysUptime = t
            }
        }
    }
    Process {
        id: saveAvatar
        command: ["sh", "-c", 'mkdir -p "$(dirname "$1")" && printf %s "$2" > "$1"',
                  "saveavatar", root.avatarSavePath, root.avatarChar]
    }
    FileView {
        id: avatarSave
        path: root.avatarSavePath
        watchChanges: false
        onLoaded: {
            const t = avatarSave.text().trim()
            if (t !== "") root.avatarChar = t
        }
        onLoadFailed: {}     }
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: upProc.running = true
    }
    Component.onCompleted: {
        userProc.running = true
        hostProc.running = true
        upProc.running = true
    }
}