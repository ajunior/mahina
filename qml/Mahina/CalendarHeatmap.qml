pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// GitHub-style contribution heatmap. Pass a JS object mapping "YYYY-MM-DD" → count.
//
// Usage:
//   CalendarHeatmap {
//       values: { "2026-01-05": 3, "2026-03-14": 7, "2026-06-01": 2 }
//       color:  Theme.success
//       label:  "Commits this year"
//   }
Item {
    id: root

    property var    values:     ({})
    property int    weeks:      52
    property color  color:      Theme.primary
    property int    maxValue:   0      // 0 = auto-detect
    property bool   showMonths: true
    property string label:      ""

    implicitWidth:  weeks * 13 + 32
    implicitHeight: 7 * 13 + (label !== "" ? 30 : 18)

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onValuesChanged(): void { _canvas.requestPaint() }
            function onColorChanged(): void { _canvas.requestPaint() }
            function onWeeksChanged(): void { _canvas.requestPaint() }
            function onWidthChanged(): void { _canvas.requestPaint() }
            function onHeightChanged(): void { _canvas.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx  = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var vals   = root.values || {}
            var cols   = root.weeks
            var cs     = 11
            var g      = 2
            var step   = cs + g
            var offX   = root.showMonths ? 26 : 4
            var offY   = root.showMonths ? 18 : 4

            var mx = root.maxValue
            if (mx === 0) {
                for (var k in vals) { var v2 = vals[k]; if (v2 > mx) mx = v2 }
                if (mx === 0) mx = 1
            }

            var today = new Date()
            var startDate = new Date(today)
            startDate.setDate(today.getDate() - cols * 7 + 1)
            startDate.setDate(startDate.getDate() - startDate.getDay())

            var bg       = Qt.color(Theme.panel)
            var col2     = Qt.color(root.color)
            var prevMonth = -1

            for (var week = 0; week < cols; week++) {
                for (var day = 0; day < 7; day++) {
                    var d = new Date(startDate)
                    d.setDate(startDate.getDate() + week * 7 + day)
                    var key = d.getFullYear() + "-"
                           + String(d.getMonth() + 1).padStart(2, "0") + "-"
                           + String(d.getDate()).padStart(2, "0")
                    var cnt  = vals[key] || 0
                    var frac = Math.min(1, cnt / mx)
                    var x    = offX + week * step
                    var y    = offY + day  * step

                    ctx.fillStyle = cnt === 0
                        ? bg.toString()
                        : Qt.rgba(col2.r, col2.g, col2.b, 0.18 + frac * 0.82).toString()
                    ctx.beginPath()
                    var r = 2
                    ctx.moveTo(x+r, y);  ctx.lineTo(x+cs-r, y)
                    ctx.arcTo(x+cs, y, x+cs, y+r, r)
                    ctx.lineTo(x+cs, y+cs-r)
                    ctx.arcTo(x+cs, y+cs, x+cs-r, y+cs, r)
                    ctx.lineTo(x+r, y+cs)
                    ctx.arcTo(x, y+cs, x, y+cs-r, r)
                    ctx.lineTo(x, y+r)
                    ctx.arcTo(x, y, x+r, y, r)
                    ctx.closePath()
                    ctx.fill()

                    if (root.showMonths && day === 0 && d.getMonth() !== prevMonth) {
                        prevMonth = d.getMonth()
                        var months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
                        ctx.fillStyle = Qt.color(Theme.textDisabled).toString()
                        ctx.font = "9px '" + Theme.fontFamily + "'"
                        ctx.textAlign = "left"
                        ctx.fillText(months[d.getMonth()], x, offY - 3)
                    }
                }
            }

            // Day-of-week labels (Mon / Wed / Fri)
            var days = ["","M","","W","","F",""]
            ctx.fillStyle = Qt.color(Theme.textDisabled).toString()
            ctx.font = "9px '" + Theme.fontFamily + "'"
            ctx.textAlign = "right"
            for (var dw = 0; dw < 7; dw++) {
                if (days[dw] !== "") {
                    ctx.fillText(days[dw], offX - 4, offY + dw * step + cs - 1)
                }
            }

            if (root.label !== "") {
                ctx.fillStyle = Qt.color(Theme.textDisabled).toString()
                ctx.font = "10px '" + Theme.fontFamily + "'"
                ctx.textAlign = "left"
                ctx.fillText(root.label, offX, height - 4)
            }
        }
    }
}
