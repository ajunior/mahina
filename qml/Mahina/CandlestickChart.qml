pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// OHLC candlestick chart for financial data.
//
// Usage:
//   CandlestickChart {
//       candles: [
//           { label: "Mon", open: 100, high: 115, low: 95,  close: 108 },
//           { label: "Tue", open: 108, high: 120, low: 105, close: 102 },
//       ]
//       upColor:   Theme.success
//       downColor: Theme.error
//   }
Item {
    id: root

    property var   candles:   []
    property color upColor:   Theme.success
    property color downColor: Theme.error
    property bool  showLabels: true

    implicitWidth:  400
    implicitHeight: 260

    Canvas {
        id:           _cc
        anchors.fill: parent

        Connections {
            target: root
            function onCandlesChanged()    { _cc.requestPaint() }
            function onWidthChanged()      { _cc.requestPaint() }
            function onHeightChanged()     { _cc.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var cd = root.candles
            if (cd.length === 0) return

            var padL = 10, padR = 10
            var padT = 16, padB = root.showLabels ? 28 : 10
            var plotW = width  - padL - padR
            var plotH = height - padT - padB

            // Find global min/max
            var lo = cd[0].low, hi = cd[0].high
            for (var i = 1; i < cd.length; i++) {
                if (cd[i].low  < lo) lo = cd[i].low
                if (cd[i].high > hi) hi = cd[i].high
            }
            if (hi === lo) { hi += 1 }
            var rng = hi - lo

            var barW   = Math.max(4, plotW / cd.length * 0.55)
            var spacing = plotW / cd.length

            function py(v) { return padT + plotH - (v - lo) / rng * plotH }

            // Y grid lines
            ctx.strokeStyle = Qt.color(Theme.border).toString()
            ctx.lineWidth   = 0.6
            for (var g = 0; g <= 4; g++) {
                var gy = padT + g * plotH / 4
                ctx.beginPath(); ctx.moveTo(padL, gy); ctx.lineTo(padL + plotW, gy); ctx.stroke()
                ctx.fillStyle   = Qt.color(Theme.textDisabled).toString()
                ctx.textAlign   = "right"; ctx.font = "9px '" + Theme.fontFamily + "'"
                ctx.fillText((hi - (hi - lo) * g / 4).toFixed(0), padL - 2, gy + 3)
            }

            // Draw candles
            for (var j = 0; j < cd.length; j++) {
                var c    = cd[j]
                var cx   = padL + j * spacing + spacing / 2
                var isUp = c.close >= c.open
                var col  = isUp ? Qt.color(root.upColor).toString() : Qt.color(root.downColor).toString()

                // Wick
                ctx.strokeStyle = col
                ctx.lineWidth   = 1.5
                ctx.beginPath()
                ctx.moveTo(cx, py(c.high))
                ctx.lineTo(cx, py(c.low))
                ctx.stroke()

                // Body
                var bodyTop = py(Math.max(c.open, c.close))
                var bodyBot = py(Math.min(c.open, c.close))
                var bodyH   = Math.max(2, bodyBot - bodyTop)
                ctx.fillStyle = col
                ctx.fillRect(cx - barW / 2, bodyTop, barW, bodyH)

                // Label
                if (root.showLabels && c.label) {
                    ctx.fillStyle   = Qt.color(Theme.textDisabled).toString()
                    ctx.textAlign   = "center"; ctx.font = "9px '" + Theme.fontFamily + "'"
                    ctx.fillText(c.label, cx, height - 8)
                }
            }
        }
    }
}
