pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Tiny inline chart for embedding in tables, stat cards, and lists.
// Supports line, area, and bar types.
//
// Usage:
//   Sparkline { values: [3, 7, 2, 9, 4, 8, 5]; width: 80; height: 32 }
//   Sparkline { values: weeklyStats; type: "bar"; color: Theme.success }
//   Sparkline { values: cpuLoad; type: "area"; strokeWidth: 1.5 }
Item {
    id: root

    property var    values:      []        // array of numbers
    property string type:        "line"    // "line" | "area" | "bar"
    property color  color:       Theme.primary
    property real   strokeWidth: 1.5
    property real   fillOpacity: 0.15
    property real   barGap:      2         // gap between bars

    implicitWidth:  80
    implicitHeight: 32

    readonly property real _min: {
        if (values.length === 0) return 0
        var m = values[0]
        for (var i = 1; i < values.length; i++) if (values[i] < m) m = values[i]
        return m
    }
    readonly property real _max: {
        if (values.length === 0) return 1
        var m = values[0]
        for (var i = 1; i < values.length; i++) if (values[i] > m) m = values[i]
        return m === _min ? _min + 1 : m
    }

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onValuesChanged()      { _canvas.requestPaint() }
            function onColorChanged()      { _canvas.requestPaint() }
            function onTypeChanged()       { _canvas.requestPaint() }
            function onStrokeWidthChanged(){ _canvas.requestPaint() }
            function onFillOpacityChanged(){ _canvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var d   = root.values
            var n   = d.length
            if (n < 2 && root.type !== "bar") return
            if (n === 0) return

            var minV = root._min
            var maxV = root._max
            var rng  = maxV - minV

            function fy(v) { return height - ((v - minV) / rng) * height }

            function roundRect(x, y, w, h, r) {
                r = Math.min(r, w / 2, h / 2)
                ctx.moveTo(x + r, y)
                ctx.lineTo(x + w - r, y)
                ctx.arcTo(x + w, y, x + w, y + r, r)
                ctx.lineTo(x + w, y + h - r)
                ctx.arcTo(x + w, y + h, x + w - r, y + h, r)
                ctx.lineTo(x + r, y + h)
                ctx.arcTo(x, y + h, x, y + h - r, r)
                ctx.lineTo(x, y + r)
                ctx.arcTo(x, y, x + r, y, r)
                ctx.closePath()
            }

            if (root.type === "bar") {
                var barW = (width - (n - 1) * root.barGap) / n
                for (var i = 0; i < n; i++) {
                    var bx = i * (barW + root.barGap)
                    var bh = ((d[i] - minV) / rng) * height
                    var by = height - bh
                    ctx.beginPath()
                    roundRect(bx, by, barW, bh, 2)
                    ctx.fillStyle = root.color.toString()
                    ctx.fill()
                }
                return
            }

            // Build points
            var pts = []
            var stepX = width / (n - 1)
            for (var j = 0; j < n; j++)
                pts.push({ x: j * stepX, y: fy(d[j]) })

            // Area fill
            if (root.type === "area") {
                ctx.beginPath()
                ctx.moveTo(pts[0].x, height)
                ctx.lineTo(pts[0].x, pts[0].y)
                for (var k = 1; k < pts.length; k++) {
                    var prev = pts[k - 1], curr = pts[k]
                    var cpx = (prev.x + curr.x) / 2
                    ctx.bezierCurveTo(cpx, prev.y, cpx, curr.y, curr.x, curr.y)
                }
                ctx.lineTo(pts[pts.length - 1].x, height)
                ctx.closePath()
                var col = root.color
                ctx.fillStyle = Qt.rgba(col.r, col.g, col.b, root.fillOpacity).toString()
                ctx.fill()
            }

            // Line
            ctx.beginPath()
            ctx.moveTo(pts[0].x, pts[0].y)
            for (var l = 1; l < pts.length; l++) {
                var p = pts[l - 1], q = pts[l]
                var cpx2 = (p.x + q.x) / 2
                ctx.bezierCurveTo(cpx2, p.y, cpx2, q.y, q.x, q.y)
            }
            ctx.strokeStyle = root.color.toString()
            ctx.lineWidth   = root.strokeWidth
            ctx.lineJoin    = "round"
            ctx.lineCap     = "round"
            ctx.stroke()

            // End dot
            var last = pts[pts.length - 1]
            ctx.beginPath()
            ctx.arc(last.x, last.y, root.strokeWidth + 1, 0, Math.PI * 2)
            ctx.fillStyle = root.color.toString()
            ctx.fill()
        }
    }
}
