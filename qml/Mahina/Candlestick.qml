pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// OHLC candlestick chart for financial/time-series data.
//
// Usage:
//   Candlestick {
//       candles: [
//           { date: "Jan 1",  open: 100, high: 115, low: 95,  close: 110 },
//           { date: "Jan 2",  open: 110, high: 120, low: 105, close: 108 },
//           { date: "Jan 3",  open: 108, high: 125, low: 102, close: 122 },
//       ]
//       width: 500; height: 240
//   }
Item {
    id: root

    property var    candles:      []
    property color  upColor:      "#26a641"
    property color  downColor:    "#f85149"
    property bool   showDates:    true
    property int    candleGap:    4

    implicitWidth:  400
    implicitHeight: 240

    readonly property real _minV: {
        if (candles.length === 0) return 0
        var m = candles[0].low ?? 0
        for (var i = 1; i < candles.length; i++) if ((candles[i].low ?? 0) < m) m = candles[i].low
        return m * 0.99
    }
    readonly property real _maxV: {
        if (candles.length === 0) return 1
        var m = candles[0].high ?? 1
        for (var i = 1; i < candles.length; i++) if ((candles[i].high ?? 0) > m) m = candles[i].high
        return m * 1.01
    }

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onCandlesChanged()  { _canvas.requestPaint() }
            function onWidthChanged()    { _canvas.requestPaint() }
            function onHeightChanged()   { _canvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var n      = root.candles.length
            if (n === 0) return

            var padL   = 40, padR = 12, padT = 12
            var padB   = root.showDates ? 28 : 12
            var plotW  = width  - padL - padR
            var plotH  = height - padT - padB
            var range  = root._maxV - root._minV

            function fy(v) { return padT + plotH - ((v - root._minV) / range) * plotH }

            var cw = (plotW / n) - root.candleGap

            // Y axis grid
            ctx.font      = "10px '" + Theme.fontFamily + "'"
            ctx.fillStyle = Theme.textSecondary.toString()
            ctx.textAlign = "right"
            for (var g = 0; g <= 4; g++) {
                var gv   = root._minV + (g / 4) * range
                var gy   = fy(gv)
                ctx.beginPath()
                ctx.moveTo(padL, gy)
                ctx.lineTo(width - padR, gy)
                ctx.strokeStyle = Theme.border.toString()
                ctx.lineWidth   = 1
                ctx.stroke()
                ctx.fillText(gv.toFixed(0), padL - 4, gy + 4)
            }

            // Candles
            for (var i = 0; i < n; i++) {
                var c    = root.candles[i]
                var o    = c.open  ?? 0
                var h    = c.high  ?? 0
                var l    = c.low   ?? 0
                var cl   = c.close ?? 0
                var up   = cl >= o
                var col  = up ? root.upColor : root.downColor

                var cx   = padL + i * (plotW / n) + (plotW / n) / 2

                // Wick
                ctx.beginPath()
                ctx.moveTo(cx, fy(h))
                ctx.lineTo(cx, fy(l))
                ctx.strokeStyle = col.toString()
                ctx.lineWidth   = 1
                ctx.stroke()

                // Body
                var bodyTop = fy(Math.max(o, cl))
                var bodyBot = fy(Math.min(o, cl))
                var bodyH   = Math.max(1, bodyBot - bodyTop)
                ctx.fillStyle = col.toString()
                ctx.fillRect(cx - cw / 2, bodyTop, cw, bodyH)

                // Date label
                if (root.showDates && (c.date ?? "") !== "") {
                    ctx.fillStyle   = Theme.textDisabled.toString()
                    ctx.textAlign   = "center"
                    ctx.fillText(c.date, cx, height - 6)
                }
            }
        }
    }
}
