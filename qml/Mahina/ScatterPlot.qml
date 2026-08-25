import QtQuick
import Mahina

// X-Y scatter plot with optional bubble sizing and color encoding.
//
// Usage:
//   ScatterPlot {
//       series: [
//           { label: "Group A", color: Theme.primary,
//             points: [{x:1.2, y:3.4}, {x:2.1, y:1.8, size:12}] },
//           { label: "Group B", color: Theme.success,
//             points: [{x:3.5, y:4.1}, {x:4.2, y:2.9}] },
//       ]
//       xLabel: "Revenue ($k)"; yLabel: "Growth (%)"
//   }
Item {
    id: root

    property var    series:   []
    property string xLabel:   ""
    property string yLabel:   ""
    property bool   showGrid: true
    property bool   showLegend: true
    property real   defaultPointSize: 8

    implicitWidth:  400
    implicitHeight: 280

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

            var padL = 44, padR = 16, padT = 12
            var padB = root.xLabel !== "" ? 40 : 24
            var legH = root.showLegend ? 22 : 0
            padT += legH

            var plotW = width  - padL - padR
            var plotH = height - padT - padB

            // Global axis bounds
            var xMin = Infinity, xMax = -Infinity, yMin = Infinity, yMax = -Infinity
            for (var si = 0; si < root.series.length; si++) {
                var pts = root.series[si].points || []
                for (var pi = 0; pi < pts.length; pi++) {
                    if (pts[pi].x < xMin) xMin = pts[pi].x
                    if (pts[pi].x > xMax) xMax = pts[pi].x
                    if (pts[pi].y < yMin) yMin = pts[pi].y
                    if (pts[pi].y > yMax) yMax = pts[pi].y
                }
            }
            if (!isFinite(xMin)) return
            var xPad = (xMax - xMin) * 0.1 || 1
            var yPad = (yMax - yMin) * 0.1 || 1
            xMin -= xPad; xMax += xPad; yMin -= yPad; yMax += yPad

            function px(x) { return padL + (x - xMin) / (xMax - xMin) * plotW }
            function py(y) { return padT + plotH - (y - yMin) / (yMax - yMin) * plotH }

            // Grid + axis labels
            if (root.showGrid) {
                ctx.strokeStyle = Qt.color(Theme.border).toString()
                ctx.lineWidth   = 0.8
                ctx.font        = "10px system-ui"
                ctx.fillStyle   = Qt.color(Theme.textDisabled).toString()

                for (var g = 0; g <= 4; g++) {
                    var gx = xMin + (xMax - xMin) * g / 4
                    var gy = yMin + (yMax - yMin) * g / 4
                    var gpx = px(gx), gpy = py(gy)

                    ctx.beginPath(); ctx.moveTo(gpx, padT); ctx.lineTo(gpx, padT + plotH); ctx.stroke()
                    ctx.textAlign = "center"
                    ctx.fillText(gx.toFixed(1), gpx, padT + plotH + 14)

                    ctx.beginPath(); ctx.moveTo(padL, gpy); ctx.lineTo(padL + plotW, gpy); ctx.stroke()
                    ctx.textAlign = "right"
                    ctx.fillText(gy.toFixed(1), padL - 4, gpy + 4)
                }
            }

            // Axis borders
            ctx.strokeStyle = Qt.color(Theme.border).toString()
            ctx.lineWidth = 1
            ctx.beginPath(); ctx.moveTo(padL, padT); ctx.lineTo(padL, padT + plotH); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(padL, padT + plotH); ctx.lineTo(padL + plotW, padT + plotH); ctx.stroke()

            // Axis labels
            if (root.xLabel !== "") {
                ctx.fillStyle = Qt.color(Theme.textSecondary).toString()
                ctx.textAlign = "center"; ctx.font = "11px system-ui"
                ctx.fillText(root.xLabel, padL + plotW/2, height - 4)
            }
            if (root.yLabel !== "") {
                ctx.save()
                ctx.translate(12, padT + plotH/2)
                ctx.rotate(-Math.PI/2)
                ctx.fillStyle = Qt.color(Theme.textSecondary).toString()
                ctx.textAlign = "center"; ctx.font = "11px system-ui"
                ctx.fillText(root.yLabel, 0, 0)
                ctx.restore()
            }

            // Legend
            if (root.showLegend) {
                var lx = padL; var ly = 4
                ctx.font = "10px system-ui"; ctx.textAlign = "left"
                for (var li = 0; li < root.series.length; li++) {
                    var lc = Qt.color(root.series[li].color || Theme.primary)
                    ctx.fillStyle = lc.toString()
                    ctx.beginPath(); ctx.arc(lx + 5, ly + 6, 5, 0, Math.PI*2); ctx.fill()
                    ctx.fillStyle = Qt.color(Theme.textSecondary).toString()
                    ctx.fillText(root.series[li].label || "", lx + 14, ly + 10)
                    lx += ctx.measureText(root.series[li].label || "").width + 30
                }
            }

            // Points
            for (var sci = 0; sci < root.series.length; sci++) {
                var serie = root.series[sci]
                var col   = Qt.color(serie.color || Theme.primary)
                var spts  = serie.points || []

                for (var spi = 0; spi < spts.length; spi++) {
                    var pt  = spts[spi]
                    var r   = (pt.size || root.defaultPointSize) / 2
                    var spx = px(pt.x), spy = py(pt.y)

                    ctx.beginPath()
                    ctx.arc(spx, spy, r, 0, Math.PI*2)
                    ctx.fillStyle = Qt.rgba(col.r, col.g, col.b, 0.75).toString()
                    ctx.fill()
                    ctx.strokeStyle = col.toString(); ctx.lineWidth = 1
                    ctx.stroke()
                }
            }
        }
    }
}
