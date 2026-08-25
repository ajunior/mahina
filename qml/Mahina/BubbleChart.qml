import QtQuick
import Mahina

// Scatter plot where each point's size encodes a third dimension.
//
// Usage:
//   BubbleChart {
//       series: [
//           { label: "Group A", color: Theme.primary,
//             points: [{ x: 10, y: 20, r: 5 }, { x: 50, y: 60, r: 12 }] },
//           { label: "Group B", color: Theme.success,
//             points: [{ x: 30, y: 70, r: 8 }, { x: 80, y: 30, r: 15 }] },
//       ]
//       xLabel: "Revenue ($k)"; yLabel: "Growth (%)"
//   }
//
// x, y: data values; r: bubble radius in px (not a fraction).
Item {
    id: root

    property var    series:   []
    property string xLabel:  ""
    property string yLabel:  ""
    property bool   showLegend: true
    property real   fillOpacity: 0.5

    implicitWidth:  400
    implicitHeight: 300

    readonly property real _xMin: {
        var m = 0
        for (var si = 0; si < series.length; si++)
            for (var pi = 0; pi < (series[si].points ?? []).length; pi++) {
                var v = (series[si].points[pi].x ?? 0) - (series[si].points[pi].r ?? 0)
                if (v < m) m = v
            }
        return m
    }
    readonly property real _xMax: {
        var m = 1
        for (var si = 0; si < series.length; si++)
            for (var pi = 0; pi < (series[si].points ?? []).length; pi++) {
                var v = (series[si].points[pi].x ?? 0) + (series[si].points[pi].r ?? 0)
                if (v > m) m = v
            }
        return m
    }
    readonly property real _yMin: {
        var m = 0
        for (var si = 0; si < series.length; si++)
            for (var pi = 0; pi < (series[si].points ?? []).length; pi++) {
                var v = (series[si].points[pi].y ?? 0)
                if (v < m) m = v
            }
        return m
    }
    readonly property real _yMax: {
        var m = 1
        for (var si = 0; si < series.length; si++)
            for (var pi = 0; pi < (series[si].points ?? []).length; pi++) {
                var v = (series[si].points[pi].y ?? 0)
                if (v > m) m = v
            }
        return m
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

        onPaint: {
            var ctx  = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var padL = 48, padR = 16, padT = 16
            var padB = root.yLabel !== "" ? 40 : 28
            var plotW = width  - padL - padR
            var plotH = height - padT - padB - (root.showLegend && root.series.length > 0 ? 24 : 0)

            var xRange = root._xMax - root._xMin || 1
            var yRange = root._yMax - root._yMin || 1

            function fx(v) { return padL + ((v - root._xMin) / xRange) * plotW }
            function fy(v) { return padT + plotH - ((v - root._yMin) / yRange) * plotH }

            // Grid
            ctx.font      = "10px system-ui"
            ctx.textAlign = "right"
            for (var g = 0; g <= 4; g++) {
                var gv = root._yMin + (g / 4) * yRange
                var gy = fy(gv)
                ctx.beginPath()
                ctx.moveTo(padL, gy); ctx.lineTo(padL + plotW, gy)
                ctx.strokeStyle = Theme.border.toString(); ctx.lineWidth = 1; ctx.stroke()
                ctx.fillStyle   = Theme.textDisabled.toString()
                ctx.fillText(gv.toFixed(1), padL - 4, gy + 4)
            }
            ctx.textAlign = "center"
            for (var gx = 0; gx <= 4; gx++) {
                var gxv = root._xMin + (gx / 4) * xRange
                var gxx = fx(gxv)
                ctx.fillStyle = Theme.textDisabled.toString()
                ctx.fillText(gxv.toFixed(1), gxx, padT + plotH + 14)
            }

            // Axes labels
            if (root.xLabel !== "") {
                ctx.fillStyle = Theme.textSecondary.toString()
                ctx.fillText(root.xLabel, padL + plotW / 2, height - (root.showLegend ? 28 : 4))
            }

            // Bubbles
            for (var si = 0; si < root.series.length; si++) {
                var ser  = root.series[si]
                var col  = ser.color ?? Theme.primary
                var pts  = ser.points ?? []
                for (var pi = 0; pi < pts.length; pi++) {
                    var p = pts[pi]
                    ctx.beginPath()
                    ctx.arc(fx(p.x ?? 0), fy(p.y ?? 0), p.r ?? 6, 0, Math.PI * 2)
                    ctx.fillStyle   = Qt.rgba(Qt.color(col).r, Qt.color(col).g, Qt.color(col).b, root.fillOpacity).toString()
                    ctx.fill()
                    ctx.strokeStyle = col.toString()
                    ctx.lineWidth   = 1.5
                    ctx.stroke()
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
                    width: 10; height: 10; radius: 5
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
