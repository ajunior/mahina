pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Combination bar + line chart for comparing two data series on dual axes.
//
// Usage:
//   ComboChart {
//       labels:  ["Jan","Feb","Mar","Apr"]
//       bars:    [{ label: "Revenue", color: Theme.primary, values: [120,145,98,200] }]
//       lines:   [{ label: "Growth%", color: Theme.success, values: [12,21,-8,35] }]
//   }
Item {
    id: root

    property var    labels:     []
    property var    bars:       []   // [{label, color, values:[]}]
    property var    lines:      []   // [{label, color, values:[]}]
    property bool   showGrid:   true
    property bool   showLegend: true

    implicitWidth:  420
    implicitHeight: 280

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onLabelsChanged(): void { _canvas.requestPaint() }
            function onBarsChanged(): void { _canvas.requestPaint() }
            function onLinesChanged(): void { _canvas.requestPaint() }
            function onWidthChanged(): void { _canvas.requestPaint() }
            function onHeightChanged(): void { _canvas.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var legH = root.showLegend ? 22 : 0
            var padL = 44, padR = 44, padT = legH + 8, padB = 24
            var plotW = width - padL - padR
            var plotH = height - padT - padB
            var n = root.labels.length
            if (n === 0) return

            // Bar y-axis bounds (left)
            var barMin = 0, barMax = 0
            for (var bi = 0; bi < root.bars.length; bi++) {
                var bv = root.bars[bi].values || []
                for (var bj = 0; bj < bv.length; bj++) { if (bv[bj] > barMax) barMax = bv[bj]; if (bv[bj] < barMin) barMin = bv[bj] }
            }
            if (barMax === barMin) barMax = barMin + 1

            // Line y-axis bounds (right)
            var linMin = Infinity, linMax = -Infinity
            for (var li = 0; li < root.lines.length; li++) {
                var lv = root.lines[li].values || []
                for (var lj = 0; lj < lv.length; lj++) { if (lv[lj] > linMax) linMax = lv[lj]; if (lv[lj] < linMin) linMin = lv[lj] }
            }
            if (!isFinite(linMin)) { linMin = 0; linMax = 1 }
            if (linMax === linMin) linMax = linMin + 1

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

            function allWhole(series: var): bool {
                for (var i = 0; i < series.length; i++) {
                    var vs = series[i].values || []
                    for (var j = 0; j < vs.length; j++)
                        if (!Number.isInteger(vs[j])) return false
                }
                return true
            }

            // Left (bar) axis: choose the step first, then widen the range out to
            // multiples of it. It used to split the range into four and print the
            // labels whole, so a chart topping out at 2 read 0, 1, 1, 2, 2.
            var barStep = niceStep((barMax - barMin) / 4, allWhole(root.bars))
            barMin = Math.floor(barMin / barStep + 1e-9) * barStep
            barMax = Math.ceil(barMax / barStep - 1e-9) * barStep
            if (barMax <= barMin) barMax = barMin + barStep
            var gridN  = Math.max(1, Math.round((barMax - barMin) / barStep))
            var barDec = decimals(barStep)

            // Right (line) axis shares the left one's gridlines, so it has to come
            // out in exactly gridN steps: take the smallest 1-2-5 step whose
            // multiples cover the data in gridN or fewer, and pad the top. Its
            // labels used to be toFixed(1) over arbitrary quarters.
            var linWhole = allWhole(root.lines)
            var linStep  = niceStep((linMax - linMin) / gridN, linWhole)
            while (Math.ceil(linMax / linStep - 1e-9) - Math.floor(linMin / linStep + 1e-9) > gridN)
                linStep = niceStep(linStep * 1.5, linWhole)
            linMin = Math.floor(linMin / linStep + 1e-9) * linStep
            linMax = linMin + gridN * linStep
            var linDec = decimals(linStep)

            function pyBar(v: var): var { return padT + plotH - (v - barMin) / (barMax - barMin) * plotH }
            function pyLin(v: var): var { return padT + plotH - (v - linMin) / (linMax - linMin) * plotH }
            function px(i: var, off: var, total: var): var {
                var slotW = plotW / n
                var grpOff = slotW * 0.1
                var barW = (slotW - grpOff * 2) / Math.max(total, 1)
                return padL + i * slotW + grpOff + off * barW
            }
            function barW(total: var): var {
                var slotW = plotW / n
                return (slotW * 0.8) / Math.max(total, 1)
            }

            // Grid lines
            if (root.showGrid) {
                ctx.strokeStyle = Qt.color(Theme.border).toString()
                ctx.lineWidth   = 0.7
                for (var g = 0; g <= gridN; g++) {
                    var gy = padT + plotH - g * plotH / gridN
                    ctx.beginPath(); ctx.moveTo(padL, gy); ctx.lineTo(padL + plotW, gy); ctx.stroke()
                    ctx.fillStyle   = Qt.color(Theme.textDisabled).toString()
                    ctx.textAlign   = "right"; ctx.font = "10px '" + Theme.fontFamily + "'"
                    var labVal = barMin + g * barStep
                    ctx.fillText(labVal.toFixed(barDec), padL - 4, gy + 4)
                    // Right axis labels (lines)
                    if (root.lines.length > 0) {
                        ctx.textAlign = "left"
                        var rVal = linMin + g * linStep
                        ctx.fillText(rVal.toFixed(linDec), padL + plotW + 4, gy + 4)
                    }
                }
            }

            // X labels + axis borders
            ctx.strokeStyle = Qt.color(Theme.border).toString()
            ctx.lineWidth = 1
            ctx.beginPath(); ctx.moveTo(padL, padT); ctx.lineTo(padL, padT + plotH); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(padL, padT + plotH); ctx.lineTo(padL + plotW, padT + plotH); ctx.stroke()
            if (root.lines.length > 0) {
                ctx.beginPath(); ctx.moveTo(padL + plotW, padT); ctx.lineTo(padL + plotW, padT + plotH); ctx.stroke()
            }

            ctx.fillStyle   = Qt.color(Theme.textSecondary).toString()
            ctx.textAlign   = "center"; ctx.font = "10px '" + Theme.fontFamily + "'"
            for (var xi = 0; xi < n; xi++) {
                var midX = padL + xi * (plotW/n) + plotW/n/2
                ctx.fillText(root.labels[xi] || "", midX, padT + plotH + 14)
            }

            // Bars
            for (var bsi = 0; bsi < root.bars.length; bsi++) {
                var bc = Qt.color(root.bars[bsi].color || Theme.primary)
                ctx.fillStyle = Qt.rgba(bc.r, bc.g, bc.b, 0.82).toString()
                var bvals = root.bars[bsi].values || []
                for (var bvi = 0; bvi < Math.min(bvals.length, n); bvi++) {
                    var bx2 = px(bvi, bsi, root.bars.length)
                    var bw2 = barW(root.bars.length)
                    var by2 = pyBar(bvals[bvi])
                    var bh2 = pyBar(0) - by2
                    if (bh2 < 0) { by2 += bh2; bh2 = -bh2 }
                    ctx.fillRect(bx2, by2, bw2, bh2)
                }
            }

            // Lines
            for (var lsi = 0; lsi < root.lines.length; lsi++) {
                var lc = Qt.color(root.lines[lsi].color || Theme.success)
                var lvals = root.lines[lsi].values || []
                ctx.strokeStyle = lc.toString()
                ctx.lineWidth = 2
                ctx.beginPath()
                for (var lvi = 0; lvi < Math.min(lvals.length, n); lvi++) {
                    var lx = padL + lvi * (plotW/n) + plotW/n/2
                    var ly = pyLin(lvals[lvi])
                    if (lvi === 0) ctx.moveTo(lx, ly); else ctx.lineTo(lx, ly)
                }
                ctx.stroke()
                // Dots
                for (var ld = 0; ld < Math.min(lvals.length, n); ld++) {
                    var ldx = padL + ld * (plotW/n) + plotW/n/2
                    var ldy = pyLin(lvals[ld])
                    ctx.beginPath(); ctx.arc(ldx, ldy, 3.5, 0, Math.PI*2)
                    ctx.fillStyle   = lc.toString(); ctx.fill()
                    ctx.strokeStyle = Qt.color(Theme.surface).toString(); ctx.lineWidth = 1.5; ctx.stroke()
                }
            }

            // Legend
            if (root.showLegend) {
                var lx2 = padL; ctx.textAlign = "left"; ctx.font = "10px '" + Theme.fontFamily + "'"
                var allSeries = root.bars.concat(root.lines)
                for (var ai = 0; ai < allSeries.length; ai++) {
                    var ac = Qt.color(allSeries[ai].color || Theme.primary)
                    var isLine = ai >= root.bars.length
                    if (isLine) {
                        ctx.strokeStyle = ac.toString(); ctx.lineWidth = 2
                        ctx.beginPath(); ctx.moveTo(lx2, 9); ctx.lineTo(lx2 + 12, 9); ctx.stroke()
                        ctx.beginPath(); ctx.arc(lx2+6, 9, 2.5, 0, Math.PI*2); ctx.fillStyle = ac.toString(); ctx.fill()
                    } else {
                        ctx.fillStyle = ac.toString()
                        ctx.fillRect(lx2, 3, 12, 12)
                    }
                    ctx.fillStyle = Qt.color(Theme.textSecondary).toString()
                    ctx.fillText(allSeries[ai].label || "", lx2 + 16, 12)
                    lx2 += ctx.measureText(allSeries[ai].label || "").width + 36
                }
            }
        }
    }
}
