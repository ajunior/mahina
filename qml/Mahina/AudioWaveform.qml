pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Animated audio waveform — idle shimmer or live amplitude bars.
//
// Usage:
//   AudioWaveform {
//       amplitudes: [0.2, 0.8, 0.5, 1.0, 0.3, 0.7, 0.4]  // 0..1
//       waveColor:  Theme.primary
//       animating:  false   // true = play idle shimmer
//   }
Item {
    id: root

    property var    amplitudes: []
    property color  waveColor:  Theme.primary
    property bool   animating:  false
    property int    barCount:   32
    property real   barGap:     2
    property bool   symmetric:  true

    implicitWidth:  240
    implicitHeight: 60

    readonly property var _bars: {
        var amps = root.amplitudes
        if (amps.length > 0) return amps
        // Idle: generate random-looking static bars
        var out = []
        for (var i = 0; i < root.barCount; i++)
            out.push(0.15 + 0.1 * Math.sin(i * 0.7))
        return out
    }

    // Shimmer phase for idle animation
    property real _phase: 0
    NumberAnimation on _phase {
        from: 0; to: Math.PI * 2; duration: 1800
        loops: Animation.Infinite; running: root.animating
    }

    Canvas {
        id:           _wc
        anchors.fill: parent

        Connections {
            target: root
            function onAmplitudesChanged() { _wc.requestPaint() }
            function onAnimatingChanged()  { _wc.requestPaint() }
            function on_PhaseChanged()     { _wc.requestPaint() }
            function onWidthChanged()      { _wc.requestPaint() }
            function onHeightChanged()     { _wc.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var bars = root._bars
            if (bars.length === 0) return

            var n   = bars.length
            var bw  = Math.max(1, (width - (n - 1) * root.barGap) / n)
            var cx  = width / 2, cy = height / 2
            var col = Qt.color(root.waveColor)

            for (var i = 0; i < n; i++) {
                var amp = bars[i]
                if (root.animating) {
                    amp = 0.2 + 0.35 * (0.5 + 0.5 * Math.sin(root._phase + i * 0.5))
                }
                var bh  = Math.max(2, amp * height * (root.symmetric ? 0.48 : 0.9))
                var bx  = i * (bw + root.barGap)
                var by  = root.symmetric ? cy - bh / 2 : height - bh

                // Gradient alpha: bright in center, fade at edges
                var edgeDist = Math.abs(i - n / 2) / (n / 2)
                var alpha = (1 - edgeDist * 0.5) * (0.5 + amp * 0.5)

                ctx.fillStyle = Qt.rgba(col.r, col.g, col.b, alpha).toString()
                ctx.beginPath()
                ctx.rect(bx, by, bw, bh)
                ctx.fill()
            }
        }
    }
}
