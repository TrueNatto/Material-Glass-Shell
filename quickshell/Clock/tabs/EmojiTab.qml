import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import "../components"

Item {
    id: root

    required property Theme theme

    readonly property string emojiPath: Quickshell.shellDir + "/data/emoji-data.json"
    readonly property string iconsPath: Quickshell.shellDir + "/data/nerdfont-icons.json"

    // ---- data state ----
    property string mode: "Emoji"        // "Emoji" | "Icons"
    property var allEmojis: []           // full emoji list, kept in memory
    property var allIcons: []            // full nerd-font icon list, kept in memory
    property var filtered: []            // result of query + category filter
    property string query: ""
    property string category: "All"

    readonly property var categories: [
        { label: "All", key: "All" },
        { label: "Smileys", key: "Smileys & Emotion" },
        { label: "People", key: "People & Body" },
        { label: "Animals", key: "Animals & Nature" },
        { label: "Food", key: "Food & Drink" },
        { label: "Travel", key: "Travel & Places" },
        { label: "Activities", key: "Activities" },
        { label: "Objects", key: "Objects" },
        { label: "Symbols", key: "Symbols" },
        { label: "Flags", key: "Flags" }
    ]

    readonly property var iconGroups: [
        { label: "All", key: "All" },
        { label: "FontAwesome", key: "fa" },
        { label: "Material", key: "md" },
        { label: "Dev", key: "dev" },
        { label: "VSCode", key: "cod" },
        { label: "Octicons", key: "oct" },
        { label: "Weather", key: "weather" },
        { label: "Seti", key: "seti" },
        { label: "Linux", key: "linux" },
        { label: "Fae", key: "fae" },
        { label: "Custom", key: "custom" },
        { label: "Other", key: "Other" }
    ]

    readonly property var knownGroups: ["fa", "md", "dev", "cod", "oct", "weather", "seti", "linux", "fae", "custom"]

    // ---- copy feedback state ----
    property string copiedEmoji: ""
    property bool toastVisible: false
    property bool searchFocused: false

    function releaseSearch() {
        searchField.activeFocus = false
    }

    function applyFilter() {
        const q = root.query.trim().toLowerCase()
        const cat = root.category
        const iconMode = root.mode === "Icons"
        const data = iconMode ? root.allIcons : root.allEmojis

        const inGroup = (e) => {
            if (cat === "All") return true
            if (!iconMode) return e.category === cat
            if (cat === "Other") return root.knownGroups.indexOf(e.group) < 0
            return e.group === cat
        }

        let out
        if (q === "") {
            out = cat === "All" ? data.slice(0) : data.filter(inGroup)
        } else {
            out = data.filter(e => {
                if (!inGroup(e)) return false
                if (e.icon && e.icon.indexOf(q) >= 0) return true
                if (e.name && e.name.indexOf(q) >= 0) return true
                const ks = e.keywords
                for (let i = 0; i < ks.length; i++) {
                    if (ks[i].indexOf(q) >= 0) return true
                }
                return false
            })
        }
        root.filtered = out
    }

    onQueryChanged: { root.applyFilter(); grid.contentY = 0 }
    onCategoryChanged: { root.applyFilter(); grid.contentY = 0 }
    onModeChanged: {
        root.category = "All"
        root.applyFilter()
        grid.contentY = 0
    }

    function switchMode(m) {
        if (root.mode === m) return
        if (m === "Icons") root.ensureIconsLoaded()
        root.mode = m
        if (root.query !== "") {
            root.query = ""
            searchField.text = ""
        }
        root.releaseSearch()
    }

    function copyEmoji(ch, name) {
        if (copyProc.running) return
        copyProc.command = ["wl-copy", ch]
        copyProc.running = true
        root.copiedEmoji = ch
        root.toastVisible = true
        toastTimer.restart()
        root.releaseSearch()
    }

    Process {
        id: copyProc
        command: ["true"]
    }

    Timer {
        id: toastTimer
        interval: 900
        repeat: false
        onTriggered: root.toastVisible = false
    }

    component EmojiCell: Item {
        id: cell
        required property string emojiChar
        required property string cellName
        required property bool isIcon
        required property real cellW
        required property real cellH
        property bool hovered: false
        property bool pressed: false

        width: cell.cellW
        height: cell.cellH

        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 6
            height: parent.height - 6
            radius: 10
            color: theme.primary
            opacity: cell.hovered ? (cell.pressed ? 0.28 : 0.16) : 0
            Behavior on opacity { NumberAnimation { duration: 100 } }
        }

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: cell.hovered ? -1 : 2
            text: cell.emojiChar
            font.family: cell.isIcon ? theme.iconFont : theme.emojiFont
            font.pixelSize: cell.isIcon ? 27 : 32
            color: cell.isIcon ? "#FFFFFF" : theme.fg
            scale: cell.pressed ? 0.8 : 1
            Behavior on scale { NumberAnimation { duration: 90 } }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1
            text: cell.cellName
            color: theme.fgMuted
            font.family: theme.uiFont
            font.weight: Font.Medium
            font.pixelSize: 8
            elide: Text.ElideRight
            width: parent.width - 4
            horizontalAlignment: Text.AlignHCenter
            opacity: cell.hovered ? 1 : 0
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: cell.hovered = true
            onExited: {
                cell.hovered = false
                cell.pressed = false
            }
            onPressed: {
                cell.pressed = true
                cell.hovered = true
            }
            onReleased: cell.pressed = false
            onClicked: root.copyEmoji(cell.emojiChar, cell.cellName)
        }
    }

    property real chipsH: root.mode === "Icons" ? 90 : 58

    Column {
        anchors.fill: parent
        spacing: 10

        // ---- header: title + Emoji | Icons switch ----
        Item {
            width: parent.width
            height: 20

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.mode === "Icons" ? "\uf031" : "\uf118"
                    color: theme.primary
                    font.family: theme.iconFont
                    font.pixelSize: 15
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.mode === "Icons"
                          ? root.allIcons.length + " icons"
                          : root.allEmojis.length + " emoji"
                    color: theme.fgMuted
                    font.family: theme.uiFont
                    font.weight: Font.Black
                    font.pixelSize: 12
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Rectangle {
                    width: 52
                    height: 22
                    radius: 11
                    color: root.mode === "Emoji" ? theme.primary : theme.surfaceContainer
                    Behavior on color { ColorAnimation { duration: 110 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\uf118"
                        color: root.mode === "Emoji" ? theme.pillFg : theme.fgMuted
                        font.family: theme.iconFont
                        font.pixelSize: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.switchMode("Emoji")
                    }
                }

                Rectangle {
                    width: 52
                    height: 22
                    radius: 11
                    color: root.mode === "Icons" ? theme.primary : theme.surfaceContainer
                    Behavior on color { ColorAnimation { duration: 110 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\uf031"
                        color: root.mode === "Icons" ? theme.pillFg : theme.fgMuted
                        font.family: theme.iconFont
                        font.pixelSize: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.switchMode("Icons")
                    }
                }
            }
        }

        // ---- search box (pill, matches the rofi style) ----
        Rectangle {
            width: parent.width
            height: 40
            radius: 20
            color: theme.surfaceContainer
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.05)

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: "\uf002"
                color: theme.fgMuted
                font.family: theme.iconFont
                font.pixelSize: 14
            }

            TextField {
                id: searchField
                anchors.left: parent.left
                anchors.leftMargin: 38
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter

                text: root.query
                placeholderText: root.mode === "Icons" ? "Search icons…" : "Search emoji…"
                color: theme.fg
                selectionColor: Qt.alpha(theme.primary, 0.4)
                font.family: theme.uiFont
                font.weight: Font.Medium
                font.pixelSize: 13
                background: Item {}
                onActiveFocusChanged: root.searchFocused = activeFocus
                Keys.onEscapePressed: root.releaseSearch()
                onTextChanged: root.query = text
            }
        }

        // ---- category / family chips ----
        Flow {
            id: chipsFlow
            width: parent.width
            height: root.chipsH
            spacing: 6

            Repeater {
                model: root.mode === "Icons" ? root.iconGroups : root.categories
                delegate: Rectangle {
                    required property var modelData

                    readonly property string label: modelData.label
                    readonly property string key: modelData.key
                    readonly property bool active: root.category === key
                    width: labelChip.implicitWidth + 20
                    height: 26
                    radius: 13
                    color: active ? theme.primary : theme.surfaceContainer
                    border.width: active ? 0 : 1
                    border.color: Qt.rgba(1, 1, 1, 0.05)
                    Behavior on color { ColorAnimation { duration: 110 } }

                    Text {
                        id: labelChip
                        anchors.centerIn: parent
                        text: label
                        color: active ? theme.pillFg : theme.fg
                        font.family: theme.uiFont
                        font.weight: Font.Black
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (root.query !== "") {
                                root.query = ""
                                searchField.text = ""
                            }
                            root.category = key
                            root.releaseSearch()
                        }
                    }
                }
            }
        }

        // ---- picker grid (virtualized) ----
        Item {
            width: parent.width
            height: parent.height - 20 - 40 - root.chipsH - 30

            GridView {
                id: grid
                anchors.fill: parent
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                cacheBuffer: 300

                model: root.filtered
                cellWidth: 48
                cellHeight: 44

                delegate: EmojiCell {
                    required property var modelData
                    emojiChar: modelData.emoji !== undefined ? modelData.emoji : modelData.icon
                    cellName: modelData.name
                    isIcon: root.mode === "Icons"
                    cellW: grid.cellWidth
                    cellH: grid.cellHeight
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Loading icons…"
                color: theme.fgMuted
                font.family: theme.uiFont
                font.weight: Font.Black
                font.pixelSize: 12
                visible: root.mode === "Icons" && root.allIcons.length === 0 && !root.iconsLoaded
            }
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        width: toastRow.implicitWidth + 26
        height: 32
        radius: 16
        color: theme.surfaceContainerHigh
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)
        opacity: root.toastVisible ? 1 : 0
        visible: root.toastVisible || opacity > 0
        Behavior on opacity { NumberAnimation { duration: 120 } }

        Row {
            id: toastRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.copiedEmoji
                font.family: root.mode === "Icons" ? theme.iconFont : theme.emojiFont
                font.pixelSize: 18
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Copied!"
                color: theme.fg
                font.family: theme.uiFont
                font.weight: Font.Black
                font.pixelSize: 12
            }
        }
    }

    property bool active: false
    property bool emojiLoaded: false
    property bool iconsLoaded: false
    property bool iconsLoading: false

    property int progressiveFirst: 100
    property int progressiveBatch: 300
    property string emojiText: ""
    property int emojiFrom: 0
    property bool emojiDone: false
    property string iconText: ""
    property int iconFrom: 0
    property bool iconDone: false

    function ensureLoaded() {
        if (root.emojiLoaded) return
        root.emojiLoaded = true
        loadEmojiProc.running = true
    }

    function ensureIconsLoaded() {
        if (root.iconsLoaded || root.iconsLoading) return
        root.iconsLoading = true
        Qt.callLater(() => { loadIconsProc.running = true })
    }

    function refreshView(resetScroll) {
        root.applyFilter()
        if (resetScroll) grid.contentY = 0
    }

    function parseEntry(s) {
        try { return JSON.parse(s) } catch (e) { return null }
    }

    // returns next scan offset, or -1 when no more entries
    function scanChunk(text, from, count, dest) {
        const re = /\{(?:[^{}]|"(?:[^"\\]|\\.)*")*\}/g
        re.lastIndex = from
        let m
        let last = from
        for (let i = 0; i < count; i++) {
            m = re.exec(text)
            if (!m) break
            last = re.lastIndex
            const e = root.parseEntry(m[0])
            if (e) dest.push(e)
        }
        return m ? last : -1
    }

    function beginEmojiLoad(text) {
        root.allEmojis = []
        root.emojiText = text
        root.emojiFrom = 0
        root.emojiDone = false
        const next = root.scanChunk(root.emojiText, root.emojiFrom, root.progressiveFirst, root.allEmojis)
        root.emojiFrom = next
        if (next < 0) root.emojiDone = true
        root.allEmojis = root.allEmojis.slice(0)
        root.refreshView(false)
        if (!root.emojiDone) emojiBatchTimer.restart()
    }

    function processEmojiBatch() {
        if (root.emojiDone) { emojiBatchTimer.stop(); return }
        const next = root.scanChunk(root.emojiText, root.emojiFrom, root.progressiveBatch, root.allEmojis)
        root.emojiFrom = next
        if (next < 0) root.emojiDone = true
        root.allEmojis = root.allEmojis.slice(0)
        root.refreshView(false)
        if (root.emojiDone) emojiBatchTimer.stop()
    }

    function beginIconLoad(text) {
        root.allIcons = []
        root.iconText = text
        root.iconFrom = 0
        root.iconDone = false
        const next = root.scanChunk(root.iconText, root.iconFrom, root.progressiveFirst, root.allIcons)
        root.iconFrom = next
        if (next < 0) root.iconDone = true
        root.allIcons = root.allIcons.slice(0)
        root.refreshView(false)
        if (!root.iconDone) iconBatchTimer.restart()
        else root.finishIconLoad()
    }

    function processIconBatch() {
        if (root.iconDone) { iconBatchTimer.stop(); return }
        const next = root.scanChunk(root.iconText, root.iconFrom, root.progressiveBatch, root.allIcons)
        root.iconFrom = next
        if (next < 0) root.iconDone = true
        root.allIcons = root.allIcons.slice(0)
        root.refreshView(false)
        if (root.iconDone) iconBatchTimer.stop()
    }

    function finishIconLoad() {
        root.iconsLoaded = true
        root.iconsLoading = false
        root.iconText = ""
        root.iconDone = true
    }

    Timer {
        id: emojiBatchTimer
        interval: 1
        repeat: true
        onTriggered: root.processEmojiBatch()
    }

    Timer {
        id: iconBatchTimer
        interval: 1
        repeat: true
        onTriggered: root.processIconBatch()
    }

    onActiveChanged: if (root.active) root.ensureLoaded()

    Component.onCompleted: root.ensureLoaded()

    Process {
        id: loadEmojiProc
        command: ["cat", root.emojiPath]
        stdout: StdioCollector {
            onStreamFinished: {
                const txt = this.text
                Qt.callLater(() => {
                    try {
                        root.beginEmojiLoad(txt)
                    } catch (e) {
                        console.log("EmojiTab: failed to parse emoji-data.json: " + e)
                    }
                })
            }
        }
    }

    Process {
        id: loadIconsProc
        command: ["cat", root.iconsPath]
        stdout: StdioCollector {
            onStreamFinished: {
                const txt = this.text
                Qt.callLater(() => {
                    try {
                        root.beginIconLoad(txt)
                    } catch (e) {
                        console.log("EmojiTab: failed to parse nerdfont-icons.json: " + e)
                    }
                })
            }
        }
    }
}