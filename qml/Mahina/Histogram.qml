import QtQuick
import Mahina

// Frequency distribution chart. Pass raw values and it bins them automatically.
//
// Usage:
//   Histogram {
//       values: [12,15,22,18,35,42,38,22,19,14,28,31,44,17,25,33,29,21,16,40]
//       bins:   8
//       color:  Theme.primary
//       xLabel: "Response time (ms)"
//   }
Item {
    id: root

    property var    values: []
    property int    bins:   10
    property color  color:  Theme.primary
    property string xLabel: ""
    property bool   showFreq: true

    implicitWidth:  400
    implicitHeight: 240

    // Compute bin counts
    readonly property var _binData: {
        var v = root.values
        if (v.length === 0) return []
        var mn = v[0], mx = v[0]
        for (var i = 1; i < v.length; i++) { if (v[i] < mn) mn = v[i]; if (v[i] > mx) mx = v[i] }
        var bw   = (mx - mn) / root.bins || 1
        var cnts = []
        for (var b = 0; b < root.bins; b++) cnts.push({ lo: mn + b * bw, hi: mn + (b + 1) * bw, count: 0 })
        for (var vi = 0; vi < v.length; vi++) {
            var bi = Math.min(root.bins - 1, Math.floor((v[vi] - mn) / bw))
            cnts[bi].count++
        }
        return cnts
    }

    readonly property int _maxCount: {
        var m = 1
        for (var i = 0; i < _binData.length; i++) if (_binData[i].count > m) m = _binData[i].count
        return m
    }

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onValuesChanged()   { _canvas.requestPaint() }
            function onBinsChanged()     { _canvas.requestPaint() }
            function onWidthChanged()    { _canvas.requestPaint() }
            function onHeightChanged()   { _canvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var bd = root._binData
            var n  = bd.length
            if (n === 0) return

            var padL  = 44, padR = 12, padT = 12
            var padB  = root.xLabel !== "" ? 40 : 24
            var plotW = width  - padL - padR
            var plotH = height - padT - padB
            var barW  = plotW / n
            var maxC  = root._maxCount

            function fy(c) { return padT + plotH - (c / maxC) * plotH }

            // Y grid
            ctx.font = "10px '" + Theme.fontFamily + "'"; ctx.textAlign = "right"
            for (var g = 0; g <= 4; g++) {
                var gv = Math.round((g / 4) * maxC)
                var gy = fy(gv)
                ctx.beginPath(); ctx.moveTo(padL, gy); ctx.lineTo(padL + plotW, gy)
                ctx.strokeStyle = Theme.border.toString(); ctx.lineWidth = 1; ctx.stroke()
                ctx.fillStyle = Theme.textDisabled.toString()
                ctx.fillText(gv, padL - 4, gy + 4)
            }

            // Bars
            for (var i = 0; i < n; i++) {
                var bh = Math.max(1, plotH - (bd[i].count / maxC) * plotH)
                var by = fy(bd[i].count)
                ctx.fillStyle = Qt.rgba(Qt.color(root.color).r, Qt.color(root.color).g, Qt.color(root.color).b, 0.85).toString()
                ctx.fillRect(padL + i * barW + 1, by, barW - 2, plotH - by + padT)

                // Bin label (lo value)
                if (i % Math.max(1, Math.floor(n / 6)) === 0) {
                    ctx.fillStyle = Theme.textDisabled.toString()
                    ctx.textAlign = "center"
                    ctx.fillText(bd[i].lo.toFixed(0), padL + i * barW + barW / 2, padT + plotH + 14)
                }
            }

            // X label
            if (root.xLabel !== "") {
                ctx.fillStyle = Theme.textSecondary.toString()
                ctx.textAlign = "center"
                ctx.fillText(root.xLabel, padL + plotW / 2, height - 4)
            }
        }
    }
}
