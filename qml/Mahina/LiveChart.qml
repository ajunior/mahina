pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Real-time streaming line chart — call push(value) to add a data point.
//
// Usage:
//   LiveChart {
//       id: _chart
//       maxPoints: 60; lineColor: Theme.success
//       Timer { interval: 300; running: true; onTriggered: _chart.push(Math.random() * 100) }
//   }
Item {
    id: root

    property var   dataPoints: []
    property int   maxPoints:  60
    property color lineColor:  Theme.primary
    property color fillColor:  Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g,
                                       Qt.color(Theme.primary).b, 0.12)
    property bool  showFill:   true
    property bool  showDots:   false
    property bool  showGrid:   true
    property string yLabel:   ""

    implicitWidth:  400
    implicitHeight: 180

    function push(val: var): void {
        var pts = root.dataPoints.slice()
        pts.push(val)
        if (pts.length > root.maxPoints) pts.shift()
        root.dataPoints = pts
    }

    Canvas {
        id:           _lc
        anchors.fill: parent

        Connections {
            target: root
            function onDataPointsChanged(): void { _lc.requestPaint() }
            function onWidthChanged(): void { _lc.requestPaint() }
            function onHeightChanged(): void { _lc.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var pts = root.dataPoints
            if (pts.length < 2) return

            var padL = root.yLabel !== "" ? 40 : 32
            var padR = 12; var padT = 10; var padB = 22
            var plotW = width - padL - padR
            var plotH = height - padT - padB

            var mn = pts[0], mx = pts[0]
            for (var i = 1; i < pts.length; i++) {
                if (pts[i] < mn) mn = pts[i]
                if (pts[i] > mx) mx = pts[i]
            }
            if (mx === mn) { mx += 1; mn -= 1 }
            var rng = mx - mn

            function px(i: var): var { return padL + (i / (root.maxPoints - 1)) * plotW }
            function py(v: var): var { return padT + plotH - (v - mn) / rng * plotH }

            // Grid
            if (root.showGrid) {
                ctx.strokeStyle = Qt.color(Theme.border).toString()
                ctx.lineWidth   = 0.7
                for (var g = 0; g <= 4; g++) {
                    var gy = padT + g * plotH / 4
                    ctx.beginPath(); ctx.moveTo(padL, gy); ctx.lineTo(padL + plotW, gy); ctx.stroke()
                    ctx.fillStyle   = Qt.color(Theme.textDisabled).toString()
                    ctx.textAlign   = "right"; ctx.font = "9px '" + Theme.fontFamily + "'"
                    var gv = mx - (mx - mn) * g / 4
                    ctx.fillText(gv.toFixed(1), padL - 4, gy + 3)
                }
            }

            // Fill
            if (root.showFill) {
                ctx.beginPath()
                var startIdx = root.maxPoints - pts.length
                ctx.moveTo(px(startIdx), padT + plotH)
                for (var fi = 0; fi < pts.length; fi++) {
                    ctx.lineTo(px(startIdx + fi), py(pts[fi]))
                }
                ctx.lineTo(px(startIdx + pts.length - 1), padT + plotH)
                ctx.closePath()
                ctx.fillStyle = Qt.color(root.fillColor).toString()
                ctx.fill()
            }

            // Line
            var lc = Qt.color(root.lineColor)
            ctx.strokeStyle = lc.toString()
            ctx.lineWidth   = 2; ctx.lineJoin = "round"
            ctx.beginPath()
            var si = root.maxPoints - pts.length
            ctx.moveTo(px(si), py(pts[0]))
            for (var li = 1; li < pts.length; li++) ctx.lineTo(px(si + li), py(pts[li]))
            ctx.stroke()

            // Dots
            if (root.showDots) {
                ctx.fillStyle = lc.toString()
                for (var di = 0; di < pts.length; di++) {
                    ctx.beginPath(); ctx.arc(px(si + di), py(pts[di]), 2.5, 0, Math.PI*2); ctx.fill()
                }
            }

            // Latest value label
            if (pts.length > 0) {
                ctx.fillStyle = lc.toString()
                ctx.textAlign = "left"; ctx.font = "bold 10px '" + Theme.fontFamily + "'"
                ctx.fillText(pts[pts.length-1].toFixed(1), padL + plotW + 2, py(pts[pts.length-1]) + 4)
            }

            // Y label
            if (root.yLabel !== "") {
                ctx.save()
                ctx.translate(10, padT + plotH/2)
                ctx.rotate(-Math.PI/2)
                ctx.fillStyle   = Qt.color(Theme.textSecondary).toString()
                ctx.textAlign   = "center"; ctx.font = "10px '" + Theme.fontFamily + "'"
                ctx.fillText(root.yLabel, 0, 0)
                ctx.restore()
            }
        }
    }
}
