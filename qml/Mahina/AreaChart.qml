pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Stacked or overlapping filled area chart for time-series data.
//
// Usage:
//   AreaChart {
//       series: [
//           { label: "Revenue",  color: Theme.primary, values: [10,18,14,22,28,24,32] },
//           { label: "Expenses", color: Theme.error,   values: [ 8,10,12,11,15,14,18] },
//       ]
//       xLabels: ["Jan","Feb","Mar","Apr","May","Jun","Jul"]
//   }
Item {
    id: root

    property var    series:      []
    property var    xLabels:     []
    property bool   showLegend:  true
    property bool   showGrid:    true
    property real   fillOpacity: 0.25
    property bool   smooth:      true

    implicitWidth:  400
    implicitHeight: 240

    readonly property real _yMax: {
        var m = 1
        for (var si = 0; si < series.length; si++)
            for (var vi = 0; vi < (series[si].values ?? []).length; vi++) {
                var v = series[si].values[vi] ?? 0
                if (v > m) m = v
            }
        return m
    }

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onSeriesChanged()      { _canvas.requestPaint() }
            function onXLabelsChanged()     { _canvas.requestPaint() }
            function onFillOpacityChanged() { _canvas.requestPaint() }
            function onWidthChanged()       { _canvas.requestPaint() }
            function onHeightChanged()      { _canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var padL = 44, padR = 16, padT = 12
            var padB = (root.xLabels.length > 0 ? 28 : 12) + (root.showLegend && root.series.length > 0 ? 22 : 0)
            var plotW = width  - padL - padR
            var plotH = height - padT - padB
            var yMax  = root._yMax

            function fx(i, n) { return padL + (n <= 1 ? 0 : i / (n - 1)) * plotW }
            function fy(v)    { return padT + plotH - (v / yMax) * plotH }

            // Grid
            if (root.showGrid) {
                ctx.font      = "10px '" + Theme.fontFamily + "'"
                ctx.textAlign = "right"
                for (var g = 0; g <= 4; g++) {
                    var gv = (g / 4) * yMax
                    var gy = fy(gv)
                    ctx.beginPath(); ctx.moveTo(padL, gy); ctx.lineTo(padL + plotW, gy)
                    ctx.strokeStyle = Theme.border.toString(); ctx.lineWidth = 1; ctx.stroke()
                    ctx.fillStyle = Theme.textDisabled.toString()
                    ctx.fillText(gv.toFixed(0), padL - 4, gy + 4)
                }
            }

            // X labels
            if (root.xLabels.length > 0) {
                ctx.fillStyle = Theme.textDisabled.toString()
                ctx.textAlign = "center"
                ctx.font = "10px '" + Theme.fontFamily + "'"
                for (var xi = 0; xi < root.xLabels.length; xi++)
                    ctx.fillText(root.xLabels[xi], fx(xi, root.xLabels.length), padT + plotH + 16)
            }

            // Series
            for (var si = 0; si < root.series.length; si++) {
                var ser  = root.series[si]
                var vals = ser.values ?? []
                var n    = vals.length
                if (n < 2) continue
                var col  = ser.color ?? Theme.primary

                ctx.beginPath()
                ctx.moveTo(fx(0, n), fy(vals[0] ?? 0))
                for (var vi = 1; vi < n; vi++)
                    ctx.lineTo(fx(vi, n), fy(vals[vi] ?? 0))

                // Fill
                ctx.lineTo(fx(n - 1, n), padT + plotH)
                ctx.lineTo(fx(0, n), padT + plotH)
                ctx.closePath()
                ctx.fillStyle = Qt.rgba(Qt.color(col).r, Qt.color(col).g, Qt.color(col).b, root.fillOpacity).toString()
                ctx.fill()

                // Stroke
                ctx.beginPath()
                ctx.moveTo(fx(0, n), fy(vals[0] ?? 0))
                for (var vi2 = 1; vi2 < n; vi2++)
                    ctx.lineTo(fx(vi2, n), fy(vals[vi2] ?? 0))
                ctx.strokeStyle = col.toString(); ctx.lineWidth = 2; ctx.stroke()
            }
        }
    }

    // Legend
    Row {
        visible: root.showLegend && root.series.length > 0
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        spacing: Theme.sp4

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
