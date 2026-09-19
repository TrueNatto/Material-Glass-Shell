import QtQuick

Item {
    id: root

    property string kind: "volume"
    property real fraction: 0
    property bool muted: false

    property color accent: "#D0BCFF"
    property color mutedColor: "#9A95A3"
    property color trackBg: "#2A2830"
    property color chipBg: Qt.rgba(0.16, 0.14, 0.16, 0.56)
    property color onChip: "#E6E1E5"
    property string fontFamily: "Inter"
    property string iconFont: "JetBrainsMono Nerd Font"

    property real topRadius: -1
    property real bottomRadius: -1

    readonly property bool isBrightness: root.kind === "brightness"
    readonly property real waveAmplitude: 3.3
    readonly property real waveLength: 34

    readonly property real displayFraction: root.muted ? 0 : root.fraction

    readonly property color baseFill: root.accent
    readonly property color liquidColor: root.shade(root.baseFill, 0.62)
    readonly property color iconColor: root.baseFill

    function shade(color, factor) {
        return Qt.rgba(color.r * factor, color.g * factor, color.b * factor, color.a)
    }

    readonly property string iconText: {
        if (root.isBrightness) return "\uf185"
        if (root.muted || root.displayFraction <= 0) return "\uf026"
        return root.displayFraction < 0.4 ? "\uf027" : "\uf028"
    }

    implicitWidth: 50
    implicitHeight: 225

    Canvas {
        id: wave
        anchors.fill: parent
        z: 0
        opacity: 0.67

        property real paintFraction: root.displayFraction
        onPaintFractionChanged: requestPaint()
        property color paintFill: root.liquidColor
        onPaintFillChanged: requestPaint()
        property color paintTrack: root.trackBg
        onPaintTrackChanged: requestPaint()

        function roundRectPath(ctx, x, y, w, h, rTL, rTR, rBR, rBL) {
            ctx.beginPath()
            ctx.moveTo(x + rTL, y)
            ctx.lineTo(x + w - rTR, y)
            ctx.arcTo(x + w, y, x + w, y + rTR, rTR)
            ctx.lineTo(x + w, y + h - rBR)
            ctx.arcTo(x + w, y + h, x + w - rBR, y + h, rBR)
            ctx.lineTo(x + rBL, y + h)
            ctx.arcTo(x, y + h, x, y + h - rBL, rBL)
            ctx.lineTo(x, y + rTL)
            ctx.arcTo(x, y, x + rTL, y, rTL)
            ctx.closePath()
        }

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const w = width
            const h = height
            const autoR = Math.min(w, h) / 2
            const rTop = root.topRadius >= 0 ? Math.min(root.topRadius, autoR) : autoR
            const rBottom = root.bottomRadius >= 0 ? Math.min(root.bottomRadius, autoR) : autoR

            roundRectPath(ctx, 0, 0, w, h, rTop, rTop, rBottom, rBottom)
            ctx.fillStyle = root.trackBg
            ctx.fill()

            const fillH = h * root.displayFraction
            if (fillH > 0.5) {
                ctx.save()
                roundRectPath(ctx, 0, 0, w, h, rTop, rTop, rBottom, rBottom)
                ctx.clip()

                const topY = h - fillH
                const freq = 2 * Math.PI / root.waveLength
                const fillColor = root.liquidColor

                ctx.beginPath()
                ctx.moveTo(0, topY)
                for (let x = 0; x <= w; x += 1) {
                    ctx.lineTo(x, topY + root.waveAmplitude * Math.sin(x * freq))
                }
                ctx.lineWidth = 1.5
                ctx.strokeStyle = Qt.alpha(fillColor, 0.85)
                ctx.stroke()

                ctx.lineTo(w, h)
                ctx.lineTo(0, h)
                ctx.closePath()
                ctx.fillStyle = fillColor
                ctx.fill()

                ctx.restore()
            }
        }
    }

    Text {
        id: pctText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 11
        text: Math.round(root.displayFraction * 100) + "%"
        color: root.onChip
        font.family: root.fontFamily
        font.weight: Font.Bold
        font.pixelSize: 13
        z: 2
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        text: root.iconText
        color: root.iconColor
        font.family: root.iconFont
        font.pixelSize: 16
        z: 2
    }
}
