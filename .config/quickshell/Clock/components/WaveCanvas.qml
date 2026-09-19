import QtQuick

Item {
    id: root
    opacity: root.effectOpacity

    property real fraction: 0
    property color color: "#D0BCFF"
    property color trackBg: "#2A2830"
    property real amplitude: 3.3
    property real wavelength: 34
    property real effectOpacity: 0.67

    Canvas {
        id: wave
        anchors.fill: parent

        property real paintFraction: root.fraction
        onPaintFractionChanged: requestPaint()
        property color paintColor: root.color
        onPaintColorChanged: requestPaint()
        property color paintTrack: root.trackBg
        onPaintTrackChanged: requestPaint()
        property real paintAmplitude: root.amplitude
        onPaintAmplitudeChanged: requestPaint()
        property real paintWavelength: root.wavelength
        onPaintWavelengthChanged: requestPaint()

        function roundRectPath(ctx, w, h, r) {
            ctx.beginPath()
            ctx.moveTo(r, 0)
            ctx.arcTo(w, 0, w, h, r)
            ctx.arcTo(w, h, 0, h, r)
            ctx.arcTo(0, h, 0, 0, r)
            ctx.arcTo(0, 0, w, 0, r)
            ctx.closePath()
        }

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const w = width
            const h = height
            const r = Math.min(w, h) / 2
            const waveAmp = root.amplitude
            const waveLen = root.wavelength

            roundRectPath(ctx, w, h, r)
            ctx.fillStyle = root.trackBg
            ctx.fill()

            const fillH = h * Math.min(1, Math.max(0, root.fraction))
            if (fillH > 0.5) {
                ctx.save()
                roundRectPath(ctx, w, h, r)
                ctx.clip()

                const topY = h - fillH
                const freq = 2 * Math.PI / waveLen
                const fillColor = root.color

                ctx.beginPath()
                ctx.moveTo(0, topY)
                for (let x = 0; x <= w; x += 1) {
                    ctx.lineTo(x, topY + waveAmp * Math.sin(x * freq))
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
}
