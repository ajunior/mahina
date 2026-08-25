import QtQuick
import Mahina

// Polar / wind-rose chart. Each label is a sector; series stack radially.
//
// Usage:
//   PolarChart {
//       labels: ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
//       series: [
//           { label: "Calm",     color: Theme.primary, values: [5,3,8,4,6,2,7,3]    },
//           { label: "Moderate", color: Theme.success, values: [12,9,15,8,11,6,13,8] },
//       ]
//       showLegend: true
//   }
Item {
    id: root

    property var  labels:     []
    property var  series:     []
    property bool showLegend: true
    property bool showLabels: true

    implicitWidth:  300
    implicitHeight: 300

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onSeriesChanged()  { _canvas.requestPaint() }
            function onLabelsChanged()  { _canvas.requestPaint() }
            function onWidthChanged()   { _canvas.requestPaint() }
            function onHeightChanged()  { _canvas.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var n = root.labels.length
            if (n === 0 || root.series.length === 0) return

            var legendH = root.showLegend ? 24 : 0
            var cx = width / 2
            var cy = (height - legendH) / 2
            var maxR = Math.min(cx, cy) - 26

            // Max value across all series and sectors
            var gmax = 0
            for (var si = 0; si < root.series.length; si++) {
                var vals = root.series[si].values || []
                for (var vi = 0; vi < vals.length; vi++) {
                    if (vals[vi] > gmax) gmax = vals[vi]
                }
            }
            if (gmax === 0) return

            var angleStep  = (2 * Math.PI) / n
            var startAngle = -Math.PI / 2

            // Grid rings
            ctx.strokeStyle = Qt.color(Theme.border).toString()
            ctx.lineWidth   = 0.6
            for (var ring = 1; ring <= 4; ring++) {
                ctx.beginPath()
                ctx.arc(cx, cy, maxR * ring / 4, 0, Math.PI * 2)
                ctx.stroke()
            }
            // Spoke lines
            for (var sp = 0; sp < n; sp++) {
                var a0 = startAngle + sp * angleStep
                ctx.beginPath()
                ctx.moveTo(cx, cy)
                ctx.lineTo(cx + maxR * Math.cos(a0), cy + maxR * Math.sin(a0))
                ctx.stroke()
            }

            // Stacked wedges per series
            var radiusOffset = []
            for (var ri = 0; ri < n; ri++) radiusOffset.push(0)

            for (var sci = 0; sci < root.series.length; sci++) {
                var serie = root.series[sci]
                var sVals = serie.values || []
                var col   = Qt.color(serie.color || Theme.primary)

                for (var sec = 0; sec < n; sec++) {
                    var val = sVals[sec] || 0
                    var r0  = radiusOffset[sec]
                    var r1  = r0 + (val / gmax) * maxR
                    var a1  = startAngle + sec * angleStep - angleStep * 0.48
                    var a2  = a1 + angleStep * 0.96

                    ctx.beginPath()
                    if (r0 > 0) {
                        ctx.arc(cx, cy, r0, a1, a2)
                    } else {
                        ctx.moveTo(cx, cy)
                    }
                    ctx.arc(cx, cy, r1, a2, a1, true)
                    if (r0 > 0) {
                        ctx.arc(cx, cy, r0, a1, a1)
                    } else {
                        ctx.lineTo(cx, cy)
                    }
                    ctx.closePath()
                    ctx.fillStyle = Qt.rgba(col.r, col.g, col.b, 0.72).toString()
                    ctx.fill()
                    radiusOffset[sec] = r1
                }
            }

            // Sector labels
            if (root.showLabels) {
                ctx.fillStyle = Qt.color(Theme.textSecondary).toString()
                ctx.font      = "11px '" + Theme.fontFamily + "'"
                ctx.textAlign = "center"
                for (var li = 0; li < n && li < root.labels.length; li++) {
                    var la = startAngle + li * angleStep
                    var lx = cx + (maxR + 16) * Math.cos(la)
                    var ly = cy + (maxR + 16) * Math.sin(la) + 4
                    ctx.fillText(root.labels[li], lx, ly)
                }
            }

            // Legend
            if (root.showLegend && root.series.length > 0) {
                var lx = 8, ly = height - legendH + 4
                ctx.font = "10px '" + Theme.fontFamily + "'"
                for (var lgi = 0; lgi < root.series.length; lgi++) {
                    var lserie = root.series[lgi]
                    var lc = Qt.color(lserie.color || Theme.primary)
                    ctx.fillStyle = lc.toString()
                    ctx.fillRect(lx, ly + 2, 10, 10)
                    ctx.fillStyle = Qt.color(Theme.textSecondary).toString()
                    ctx.textAlign = "left"
                    ctx.fillText(lserie.label || "", lx + 14, ly + 11)
                    lx += 80
                }
            }
        }
    }
}
