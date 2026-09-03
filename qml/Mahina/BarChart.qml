pragma ComponentBehavior: Bound
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

    // The tallest value in the data, and whether the data is all whole numbers.
    readonly property real _yPeak: {
        var m = 1
        for (var si = 0; si < series.length; si++)
            for (var vi = 0; vi < (series[si].values ?? []).length; vi++) {
                var v = series[si].values[vi] ?? 0
                if (v > m) m = v
            }
        return m
    }
    readonly property bool _yWhole: {
        for (var si = 0; si < series.length; si++)
            for (var vi = 0; vi < (series[si].values ?? []).length; vi++)
                if (!Number.isInteger(series[si].values[vi] ?? 0)) return false
        return true
    }

    // The gap between gridlines, rounded to a 1-2-5 figure so the labels are
    // numbers a reader recognises. The axis used to run from 0 to the tallest
    // value in four equal parts and print every label whole: a chart topping
    // out at 2 drew its lines at 0, 0.5, 1, 1.5 and 2, and the axis read
    // 0, 1, 1, 2, 2. Counts have no meaningful half, so a series of whole
    // numbers gets whole steps even where a finer one would have divided
    // evenly; anything else keeps the fraction and prints it below.
    readonly property real _yStep: {
        var raw = root._yPeak / 4
        if (!(raw > 0)) return 1
        var mag  = Math.pow(10, Math.floor(Math.log(raw) / Math.LN10))
        var norm = raw / mag
        var step = (norm <= 1 ? 1 : norm <= 2 ? 2 : norm <= 5 ? 5 : 10) * mag
        return root._yWhole ? Math.max(1, Math.round(step)) : step
    }
    readonly property real _yMax:   Math.ceil(root._yPeak / root._yStep) * root._yStep
    readonly property int  _yLines: Math.max(1, Math.round(root._yMax / root._yStep))
    readonly property int  _yDec:   root._yStep >= 1 ? 0
                                  : Math.min(6, Math.ceil(-Math.log(root._yStep) / Math.LN10))

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
            function onSeriesChanged(): void { _canvas.requestPaint() }
            function onXLabelsChanged(): void { _canvas.requestPaint() }
            function onWidthChanged(): void { _canvas.requestPaint() }
            function onHeightChanged(): void { _canvas.requestPaint() }
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

            function fy(v: var): var { return padT + plotH - (v / yMax) * plotH }

            // Grid + Y axis labels
            if (root.showGrid) {
                ctx.font      = "10px '" + Theme.fontFamily + "'"
                ctx.textAlign = "right"
                for (var g = 0; g <= root._yLines; g++) {
                    var gv = g * root._yStep
                    var gy = fy(gv)
                    ctx.beginPath(); ctx.moveTo(padL, gy); ctx.lineTo(padL + plotW, gy)
                    ctx.strokeStyle = Theme.border.toString(); ctx.lineWidth = 1; ctx.stroke()
                    ctx.fillStyle = Theme.textDisabled.toString()
                    ctx.fillText(gv.toFixed(root._yDec), padL - 4, gy + 4)
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
