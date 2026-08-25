import QtQuick
import Mahina

// Radar / spider chart for comparing multiple dimensions across one or more series.
//
// Usage:
//   RadarChart {
//       axes:   ["Speed", "Power", "Range", "Accuracy", "Cost"]
//       series: [
//           { label: "Model A", color: Theme.primary, values: [0.8, 0.6, 0.9, 0.7, 0.5] },
//           { label: "Model B", color: Theme.success, values: [0.5, 0.9, 0.6, 0.8, 0.9] },
//       ]
//   }
//
// values are 0.0–1.0 fractions; axes and series[].values must have the same length.
Item {
    id: root

    property var axes:       []   // string labels
    property var series:     []   // [{label, color, values:[0..1]}]
    property int gridLines:  4    // concentric grid circles
    property bool showLegend: true

    implicitWidth:  300
    implicitHeight: 300

    readonly property real _cx:   width  / 2
    readonly property real _cy:   (height - (showLegend && series.length > 0 ? 24 : 0)) / 2
    readonly property real _r:    Math.min(_cx, _cy) - 32

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onAxesChanged()    { _canvas.requestPaint() }
            function onSeriesChanged()  { _canvas.requestPaint() }
            function onWidthChanged()   { _canvas.requestPaint() }
            function onHeightChanged()  { _canvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var n   = root.axes.length
            if (n < 3) return

            var cx  = root._cx
            var cy  = root._cy
            var r   = root._r

            function pt(axis, frac) {
                var angle = (axis / n) * Math.PI * 2 - Math.PI / 2
                return { x: cx + Math.cos(angle) * frac * r,
                         y: cy + Math.sin(angle) * frac * r }
            }

            // Grid rings
            for (var g = 1; g <= root.gridLines; g++) {
                var fr = g / root.gridLines
                ctx.beginPath()
                for (var a = 0; a < n; a++) {
                    var gp = pt(a, fr)
                    if (a === 0) ctx.moveTo(gp.x, gp.y)
                    else         ctx.lineTo(gp.x, gp.y)
                }
                ctx.closePath()
                ctx.strokeStyle = Theme.border.toString()
                ctx.lineWidth   = 1
                ctx.stroke()
            }

            // Axis spokes
            for (var s2 = 0; s2 < n; s2++) {
                var sp = pt(s2, 1)
                ctx.beginPath()
                ctx.moveTo(cx, cy)
                ctx.lineTo(sp.x, sp.y)
                ctx.strokeStyle = Theme.border.toString()
                ctx.lineWidth   = 1
                ctx.stroke()
            }

            // Axis labels
            ctx.font      = Theme.textXs + "px '" + Theme.fontFamily + "'"
            ctx.fillStyle = Theme.textSecondary.toString()
            ctx.textAlign = "center"
            ctx.textBaseline = "middle"
            for (var l = 0; l < n; l++) {
                var lp     = pt(l, 1.18)
                ctx.fillText(root.axes[l] ?? "", lp.x, lp.y)
            }

            // Series polygons
            for (var si = 0; si < root.series.length; si++) {
                var ser  = root.series[si]
                var vals = ser.values ?? []
                if (vals.length < n) continue

                var col = ser.color ?? Theme.primary

                ctx.beginPath()
                for (var vi = 0; vi < n; vi++) {
                    var vp = pt(vi, Math.max(0, Math.min(1, vals[vi])))
                    if (vi === 0) ctx.moveTo(vp.x, vp.y)
                    else          ctx.lineTo(vp.x, vp.y)
                }
                ctx.closePath()

                // Fill
                ctx.fillStyle   = Qt.rgba(Qt.color(col).r, Qt.color(col).g, Qt.color(col).b, 0.18).toString()
                ctx.fill()

                // Stroke
                ctx.strokeStyle = col.toString()
                ctx.lineWidth   = 2
                ctx.stroke()

                // Dots
                for (var di = 0; di < n; di++) {
                    var dp = pt(di, Math.max(0, Math.min(1, vals[di])))
                    ctx.beginPath()
                    ctx.arc(dp.x, dp.y, 3.5, 0, Math.PI * 2)
                    ctx.fillStyle = col.toString()
                    ctx.fill()
                }
            }
        }
    }

    // Legend
    Row {
        visible:  root.showLegend && root.series.length > 0
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        spacing:  Theme.sp4

        Repeater {
            model: root.series
            delegate: Row {
                id: _rq1
                required property var modelData
                spacing: Theme.sp1
                Rectangle {
                    width: 10; height: 10; radius: 2
                    color: _rq1.modelData.color ?? Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text:           _rq1.modelData.label ?? ""
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
