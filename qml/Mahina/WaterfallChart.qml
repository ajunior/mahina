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
            function onBarsChanged(): void { _canvas.requestPaint() }
            function onWidthChanged(): void { _canvas.requestPaint() }
            function onHeightChanged(): void { _canvas.requestPaint() }
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
                    // A total runs from zero, down as well as up: a negative one
                    // had its top below its base and drew as a 1 px sliver.
                    tops.push({ base: Math.min(0, v), top: Math.max(0, v) })
                    running = v
                } else {
                    var newRun = running + v
                    tops.push({ base: Math.min(running, newRun), top: Math.max(running, newRun) })
                    running = newRun
                }
                if (tops[i].top > yMax) yMax = tops[i].top
                if (tops[i].base < yMin) yMin = tops[i].base
            }

            // A 1-2-5 step close to raw: labels read as numbers people recognise,
            // and gridlines land on them. Whole-number data gets whole steps — a
            // count has no meaningful half. (Same rule as BarChart/AreaChart.)
            function niceStep(raw: real, whole: bool): real {
                if (!(raw > 0)) return 1
                var mag  = Math.pow(10, Math.floor(Math.log(raw) / Math.LN10))
                var norm = raw / mag
                var step = (norm <= 1 ? 1 : norm <= 2 ? 2 : norm <= 5 ? 5 : 10) * mag
                return whole ? Math.max(1, Math.round(step)) : step
            }
            function decimals(step: real): int {
                return step >= 1 ? 0 : Math.min(6, Math.ceil(-Math.log(step) / Math.LN10 - 1e-9))
            }

            // The axis used to split [yMin, yMax] into four and print each label
            // whole, so a small or fractional range repeated labels (0, 1, 1, 2, 2).
            // Choose the step first, then widen the range out to multiples of it:
            // the bottom snapped down, the top up, so both ends are labelled values.
            var whole = true
            for (var wi = 0; wi < n; wi++)
                if (!Number.isInteger(root.bars[wi].value ?? 0)) { whole = false; break }
            var yStep  = niceStep((yMax - yMin) / 4, whole)
            yMin = Math.floor(yMin / yStep + 1e-9) * yStep
            yMax = Math.ceil(yMax / yStep - 1e-9) * yStep
            if (yMax <= yMin) yMax = yMin + yStep
            var yLines = Math.round((yMax - yMin) / yStep)
            var yDec   = decimals(yStep)

            var range = yMax - yMin
            function fy(v: var): var { return padT + plotH - ((v - yMin) / range) * plotH }

            // Grid
            ctx.font = "10px '" + Theme.fontFamily + "'"; ctx.textAlign = "right"
            for (var g = 0; g <= yLines; g++) {
                var gv = yMin + g * yStep
                var gy = fy(gv)
                ctx.beginPath(); ctx.moveTo(padL, gy); ctx.lineTo(padL + plotW, gy)
                ctx.strokeStyle = Theme.border.toString(); ctx.lineWidth = 1; ctx.stroke()
                ctx.fillStyle = Theme.textDisabled.toString()
                ctx.fillText(gv.toFixed(yDec), padL - 4, gy + 4)
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
