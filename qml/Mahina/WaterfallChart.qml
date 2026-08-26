pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Running-total bar chart where each bar shows a delta from the previous total.
//
// Usage:
//   WaterfallChart {
//       bars: [
//           { label: "Start",    value: 1000, type: "total"    },
//           { label: "Revenue",  value:  500, type: "positive" },
//           { label: "Refunds",  value: -120, type: "negative" },
//           { label: "OpEx",     value: -300, type: "negative" },
//           { label: "Net",      value: 1080, type: "total"    },
//       ]
//   }
Item {
    id: root

    property var   bars:       []
    property color posColor:   Theme.success
    property color negColor:   Theme.error
    property color totColor:   Theme.primary
    property bool  showValues: true
    property real  barGap:     8

    implicitWidth:  420
    implicitHeight: 260

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onBarsChanged()   { _canvas.requestPaint() }
            function onWidthChanged()  { _canvas.requestPaint() }
            function onHeightChanged() { _canvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var n    = root.bars.length
            if (n === 0) return

            var padL = 44, padR = 12, padT = 20, padB = 28
            var plotW = width  - padL - padR
            var plotH = height - padT - padB
            var barW  = plotW / n - root.barGap

            // Compute running total to find y range
            var running = 0, yMin = 0, yMax = 0
            var tops = []
            for (var i = 0; i < n; i++) {
                var b = root.bars[i]
                var v = b.value ?? 0
                if ((b.type ?? "") === "total") {
                    tops.push({ base: 0, top: v })
                    running = v
                } else {
                    var newRun = running + v
                    tops.push({ base: Math.min(running, newRun), top: Math.max(running, newRun) })
                    running = newRun
                }
                if (tops[i].top > yMax) yMax = tops[i].top
                if (tops[i].base < yMin) yMin = tops[i].base
            }

            var range = yMax - yMin || 1
            function fy(v) { return padT + plotH - ((v - yMin) / range) * plotH }

            // Grid
            ctx.font = "10px '" + Theme.fontFamily + "'"; ctx.textAlign = "right"
            for (var g = 0; g <= 4; g++) {
                var gv = yMin + (g / 4) * range
                var gy = fy(gv)
                ctx.beginPath(); ctx.moveTo(padL, gy); ctx.lineTo(padL + plotW, gy)
                ctx.strokeStyle = Theme.border.toString(); ctx.lineWidth = 1; ctx.stroke()
                ctx.fillStyle = Theme.textDisabled.toString()
                ctx.fillText(gv.toFixed(0), padL - 4, gy + 4)
            }

            // Bars
            running = 0
            for (var i2 = 0; i2 < n; i2++) {
                var b2  = root.bars[i2]
                var v2  = b2.value ?? 0
                var typ = b2.type ?? "positive"
                var col = typ === "total"    ? root.totColor :
                          typ === "negative" ? root.negColor : root.posColor

                var t = tops[i2]
                var bx = padL + i2 * (plotW / n) + root.barGap / 2
                var by = fy(t.top)
                var bh = Math.max(1, fy(t.base) - fy(t.top))

                ctx.fillStyle = col.toString()
                ctx.fillRect(bx, by, barW, bh)

                // Connector line to next bar
                if (i2 < n - 1) {
                    ctx.beginPath()
                    ctx.moveTo(bx + barW, fy(typ === "total" ? v2 : (typ === "negative" ? running + v2 : running + v2)))
                    ctx.lineTo(bx + barW + root.barGap, fy(typ === "total" ? v2 : running + v2))
                    ctx.strokeStyle = Theme.border.toString(); ctx.lineWidth = 1
                    ctx.setLineDash([3, 3]); ctx.stroke(); ctx.setLineDash([])
                }

                if ((b2.type ?? "") !== "total") running += v2

                // Label
                ctx.fillStyle = Theme.textDisabled.toString()
                ctx.textAlign = "center"
                ctx.fillText(b2.label ?? "", bx + barW / 2, padT + plotH + 16)

                // Value
                if (root.showValues) {
                    ctx.fillStyle = "#ffffff"
                    if (bh > 14) ctx.fillText(v2.toFixed(0), bx + barW / 2, by + bh / 2 + 4)
                }
            }
        }
    }
}
