import QtQuick
import Mahina

// Vertical bar chart. Single series draws one bar per category; multiple series
// draw grouped bars. Values are measured from a zero baseline.
//
// Usage:
//   BarChart {
//       series: [
//           { label: "Revenue",  color: Theme.primary, values: [10,18,14,22,28] },
//           { label: "Expenses", color: Theme.error,   values: [ 8,10,12,11,15] },
//       ]
//       xLabels: ["Q1","Q2","Q3","Q4","Q5"]
//   }
Item {
    id: root

    property var  series:     []
    property var  xLabels:    []
    property bool showLegend: true
    property bool showGrid:   true

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

    readonly property int _nCat: {
        var n = root.xLabels.length
        for (var si = 0; si < series.length; si++)
            n = Math.max(n, (series[si].values ?? []).length)
        return n
    }

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onSeriesChanged()  { _canvas.requestPaint() }
            function onXLabelsChanged() { _canvas.requestPaint() }
            function onWidthChanged()   { _canvas.requestPaint() }
            function onHeightChanged()  { _canvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var padL = 44, padR = 16, padT = 12
            var padB = (root.xLabels.length > 0 ? 28 : 12) + (root.showLegend && root.series.length > 0 ? 22 : 0)
            var plotW = width  - padL - padR
            var plotH = height - padT - padB
            var yMax  = root._yMax
            var nCat  = root._nCat
            var nSer  = root.series.length
            if (nCat <= 0 || nSer <= 0 || plotW <= 0 || plotH <= 0) return

            function fy(v) { return padT + plotH - (v / yMax) * plotH }

            // Grid + Y axis labels
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

            var groupW  = plotW / nCat
            var innerPad = groupW * 0.15
            var usable  = groupW - innerPad * 2
            var barW    = usable / nSer

            // Bars
            for (var c = 0; c < nCat; c++) {
                var groupX = padL + c * groupW
                for (var s = 0; s < nSer; s++) {
                    var vals = root.series[s].values ?? []
                    var v    = vals[c] ?? 0
                    if (v <= 0) continue
                    var col  = root.series[s].color ?? Theme.primary
                    var barH = (v / yMax) * plotH
                    var x    = groupX + innerPad + s * barW
                    var y    = padT + plotH - barH
                    ctx.fillStyle = col.toString()
                    ctx.fillRect(x, y, Math.max(1, barW * 0.86), barH)
                }
            }

            // X labels (centred under each group)
            if (root.xLabels.length > 0) {
                ctx.fillStyle = Theme.textDisabled.toString()
                ctx.textAlign = "center"
                ctx.font = "10px '" + Theme.fontFamily + "'"
                for (var xi = 0; xi < root.xLabels.length; xi++)
                    ctx.fillText(root.xLabels[xi], padL + xi * groupW + groupW / 2, padT + plotH + 16)
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
