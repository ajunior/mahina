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
            function onLabelsChanged()  { _canvas.requestPaint() }
            function onBarsChanged()    { _canvas.requestPaint() }
            function onLinesChanged()   { _canvas.requestPaint() }
            function onWidthChanged()   { _canvas.requestPaint() }
            function onHeightChanged()  { _canvas.requestPaint() }
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

            function pyBar(v) { return padT + plotH - (v - barMin) / (barMax - barMin) * plotH }
            function pyLin(v) { return padT + plotH - (v - linMin) / (linMax - linMin) * plotH }
            function px(i, off, total) {
                var slotW = plotW / n
                var grpOff = slotW * 0.1
                var barW = (slotW - grpOff * 2) / Math.max(total, 1)
                return padL + i * slotW + grpOff + off * barW
            }
            function barW(total) {
                var slotW = plotW / n
                return (slotW * 0.8) / Math.max(total, 1)
            }

            // Grid lines
            if (root.showGrid) {
                ctx.strokeStyle = Qt.color(Theme.border).toString()
                ctx.lineWidth   = 0.7
                for (var g = 0; g <= 4; g++) {
                    var gy = padT + plotH - g * plotH / 4
                    ctx.beginPath(); ctx.moveTo(padL, gy); ctx.lineTo(padL + plotW, gy); ctx.stroke()
                    ctx.fillStyle   = Qt.color(Theme.textDisabled).toString()
                    ctx.textAlign   = "right"; ctx.font = "10px system-ui"
                    var labVal = barMin + (barMax - barMin) * g / 4
                    ctx.fillText(labVal.toFixed(0), padL - 4, gy + 4)
                    // Right axis labels (lines)
                    if (root.lines.length > 0) {
                        ctx.textAlign = "left"
                        var rVal = linMin + (linMax - linMin) * g / 4
                        ctx.fillText(rVal.toFixed(1), padL + plotW + 4, gy + 4)
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
            ctx.textAlign   = "center"; ctx.font = "10px system-ui"
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
                var lx2 = padL; ctx.textAlign = "left"; ctx.font = "10px system-ui"
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
