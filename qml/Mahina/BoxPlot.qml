pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Box-and-whisker plot showing five-number summary with outliers.
//
// Usage:
//   BoxPlot {
//       series: [
//           { label: "Group A", color: Theme.primary, values: [5,12,18,22,35,41,28,15,33,25,44,30] },
//           { label: "Group B", color: Theme.success, values: [8,9,14,18,22,11,16,20,25,13,17,21]  },
//       ]
//   }
Item {
    id: root

    property var  series:   []
    property bool showMean: true
    property bool showGrid: true

    implicitWidth:  360
    implicitHeight: 240

    function _stats(vals) {
        if (!vals || vals.length === 0) return null
        var sorted = vals.slice().sort(function(a, b) { return a - b })
        var n  = sorted.length
        var q1 = sorted[Math.floor(n * 0.25)]
        var q3 = sorted[Math.floor(n * 0.75)]
        var med = n % 2 === 0
            ? (sorted[Math.floor(n/2)-1] + sorted[Math.floor(n/2)]) / 2
            : sorted[Math.floor(n/2)]
        var mean = 0
        for (var i = 0; i < n; i++) mean += sorted[i]
        mean /= n
        var iqr = q3 - q1
        var loFence = q1 - 1.5 * iqr
        var hiFence = q3 + 1.5 * iqr
        var wlo = sorted[0], whi = sorted[n-1]
        for (var j = 0; j < n; j++) { if (sorted[j] >= loFence) { wlo = sorted[j]; break } }
        for (var k = n-1; k >= 0; k--) { if (sorted[k] <= hiFence) { whi = sorted[k]; break } }
        var outliers = []
        for (var l = 0; l < n; l++) {
            if (sorted[l] < loFence || sorted[l] > hiFence) outliers.push(sorted[l])
        }
        return { q1: q1, q3: q3, median: med, mean: mean, wlo: wlo, whi: whi, min: sorted[0], max: sorted[n-1], outliers: outliers }
    }

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onSeriesChanged()  { _canvas.requestPaint() }
            function onWidthChanged()   { _canvas.requestPaint() }
            function onHeightChanged()  { _canvas.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            if (root.series.length === 0) return

            var allStats = []
            var gmin = Infinity, gmax = -Infinity
            for (var si = 0; si < root.series.length; si++) {
                var st = root._stats(root.series[si].values || [])
                allStats.push(st)
                if (st) {
                    if (st.min < gmin) gmin = st.min
                    if (st.max > gmax) gmax = st.max
                }
            }
            if (!isFinite(gmin)) return
            var pad = (gmax - gmin) * 0.12
            if (pad === 0) pad = 1
            gmin -= pad; gmax += pad

            var padL = 44, padR = 16, padT = 12, padB = 28
            var plotW = width  - padL - padR
            var plotH = height - padT - padB
            var n = root.series.length

            function fy(v) { return padT + plotH - (v - gmin) / (gmax - gmin) * plotH }

            // Grid
            if (root.showGrid) {
                ctx.strokeStyle = Qt.color(Theme.border).toString()
                ctx.lineWidth = 0.8
                for (var g = 0; g <= 4; g++) {
                    var gv = gmin + (gmax - gmin) * g / 4
                    var gy = fy(gv)
                    ctx.beginPath(); ctx.moveTo(padL, gy); ctx.lineTo(padL + plotW, gy); ctx.stroke()
                    ctx.fillStyle  = Qt.color(Theme.textDisabled).toString()
                    ctx.font       = "10px '" + Theme.fontFamily + "'"
                    ctx.textAlign  = "right"
                    ctx.fillText(gv.toFixed(0), padL - 4, gy + 4)
                }
            }

            var bw = Math.min(44, plotW / n * 0.45)

            for (var i = 0; i < n; i++) {
                var stat = allStats[i]
                if (!stat) continue
                var rawColor = root.series[i].color || Theme.primary
                var col  = Qt.color(rawColor)
                var cx   = padL + (i + 0.5) * plotW / n

                // Whiskers
                ctx.strokeStyle = col.toString()
                ctx.lineWidth   = 1.5

                ctx.beginPath(); ctx.moveTo(cx, fy(stat.whi)); ctx.lineTo(cx, fy(stat.q3)); ctx.stroke()
                ctx.beginPath(); ctx.moveTo(cx, fy(stat.q1)); ctx.lineTo(cx, fy(stat.wlo)); ctx.stroke()
                // Caps
                ctx.beginPath(); ctx.moveTo(cx - bw*0.3, fy(stat.whi)); ctx.lineTo(cx + bw*0.3, fy(stat.whi)); ctx.stroke()
                ctx.beginPath(); ctx.moveTo(cx - bw*0.3, fy(stat.wlo)); ctx.lineTo(cx + bw*0.3, fy(stat.wlo)); ctx.stroke()

                // IQR box fill
                ctx.fillStyle   = Qt.rgba(col.r, col.g, col.b, 0.2).toString()
                var boxTop = fy(stat.q3), boxBot = fy(stat.q1)
                ctx.fillRect(cx - bw/2, boxTop, bw, boxBot - boxTop)

                // IQR box stroke
                ctx.strokeStyle = col.toString()
                ctx.strokeRect(cx - bw/2, boxTop, bw, boxBot - boxTop)

                // Median
                ctx.lineWidth = 2.5
                ctx.beginPath(); ctx.moveTo(cx - bw/2, fy(stat.median)); ctx.lineTo(cx + bw/2, fy(stat.median)); ctx.stroke()

                // Mean diamond
                if (root.showMean) {
                    ctx.fillStyle = col.toString()
                    ctx.beginPath()
                    ctx.moveTo(cx, fy(stat.mean) - 4)
                    ctx.lineTo(cx + 4, fy(stat.mean))
                    ctx.lineTo(cx, fy(stat.mean) + 4)
                    ctx.lineTo(cx - 4, fy(stat.mean))
                    ctx.closePath()
                    ctx.fill()
                }

                // Outliers
                ctx.fillStyle = Qt.rgba(col.r, col.g, col.b, 0.7).toString()
                for (var oi = 0; oi < stat.outliers.length; oi++) {
                    ctx.beginPath()
                    ctx.arc(cx + (Math.random()-0.5)*6, fy(stat.outliers[oi]), 3, 0, Math.PI*2)
                    ctx.fill()
                }

                // X label
                ctx.fillStyle  = Qt.color(Theme.textSecondary).toString()
                ctx.font       = "10px '" + Theme.fontFamily + "'"
                ctx.textAlign  = "center"
                ctx.fillText(root.series[i].label ?? "", cx, height - 6)
            }
        }
    }
}
