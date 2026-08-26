pragma ComponentBehavior: Bound
import QtQuick
import Mahina

Item {
    id: root

    property bool horizontal: true
    property real rulerScale:  1.0      // pixels per unit
    property real rulerOffset: 0        // scroll offset in units
    property string unit:      "px"
    property real majorStep:   100      // units between major ticks
    property real minorStep:   10       // units between minor ticks
    property real guidePos:    -1       // guide line position in units (−1 = none)

    implicitWidth:  horizontal ? 400 : 24
    implicitHeight: horizontal ? 24 : 400

    Canvas {
        id:    _canvas
        anchors.fill: parent
        onPaint: {
            var ctx  = getContext("2d")
            var w    = width
            var h    = height
            var sc   = root.rulerScale
            var off  = root.rulerOffset
            var maj  = root.majorStep
            var min  = root.minorStep
            var horiz = root.horizontal

            ctx.clearRect(0, 0, w, h)

            // Background
            ctx.fillStyle = Qt.darker(Theme.panel, 1.05).toString()
            ctx.fillRect(0, 0, w, h)

            // Border
            ctx.fillStyle = Theme.border.toString()
            if (horiz) ctx.fillRect(0, h - 1, w, 1)
            else        ctx.fillRect(w - 1, 0, 1, h)

            var len = horiz ? w : h
            var start = Math.floor(off / min) * min
            var end   = off + len / sc + min

            ctx.fillStyle   = Theme.textSecondary.toString()
            ctx.strokeStyle = Theme.border.toString()
            ctx.font        = "10px '" + Theme.fontFamily + "'"
            ctx.textAlign   = "left"

            for (var u = start; u <= end; u += min) {
                var px = (u - off) * sc
                if (px < 0 || px > len) continue

                var isMaj = Math.abs(u % maj) < 0.001 || Math.abs(u % maj - maj) < 0.001
                var tickH  = isMaj ? (horiz ? h * 0.55 : h * 0.55)
                                   : (horiz ? h * 0.3  : h * 0.3)

                ctx.beginPath()
                if (horiz) {
                    ctx.moveTo(px, h)
                    ctx.lineTo(px, h - tickH)
                } else {
                    ctx.moveTo(w, px)
                    ctx.lineTo(w - tickH, px)
                }
                ctx.lineWidth = 1
                ctx.stroke()

                if (isMaj) {
                    var label = Math.round(u).toString()
                    if (horiz) {
                        ctx.fillText(label, px + 2, 10)
                    } else {
                        ctx.save()
                        ctx.translate(10, px - 2)
                        ctx.rotate(-Math.PI / 2)
                        ctx.fillText(label, 0, 0)
                        ctx.restore()
                    }
                }
            }

            // Guide line
            if (root.guidePos >= 0) {
                var gpx = (root.guidePos - off) * sc
                ctx.strokeStyle = Theme.primary.toString()
                ctx.lineWidth   = 1
                ctx.beginPath()
                if (horiz) { ctx.moveTo(gpx, 0); ctx.lineTo(gpx, h) }
                else        { ctx.moveTo(0, gpx); ctx.lineTo(w, gpx) }
                ctx.stroke()
            }
        }
    }

    onRulerScaleChanged:  _canvas.requestPaint()
    onRulerOffsetChanged: _canvas.requestPaint()
    onGuidePosChanged:    _canvas.requestPaint()
    onWidthChanged:       _canvas.requestPaint()
    onHeightChanged:      _canvas.requestPaint()
}
