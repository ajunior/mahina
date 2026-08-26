pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// GitHub-style contribution heatmap — 52 weeks × 7 days grid.
//
// Usage:
//   HeatMapCalendar {
//       heatData: ({ "2025-01-05": 3, "2025-01-12": 7, "2025-03-20": 12 })
//       maxValue: 15
//       cellColor: Theme.success
//   }
Item {
    id: root

    property var    heatData:  ({})     // { "YYYY-MM-DD": count }
    property int    maxValue:  10
    property color  cellColor: Theme.success
    property int    weeks:     52
    property int    cellSize:  12
    property int    cellGap:   2
    property bool   showMonthLabels: true
    property bool   showDayLabels:   true

    readonly property int _stride: root.cellSize + root.cellGap
    readonly property int _labW:   root.showDayLabels ? 22 : 0
    readonly property int _labH:   root.showMonthLabels ? 18 : 0

    implicitWidth:  _labW + root.weeks * _stride
    implicitHeight: _labH + 7 * _stride

    Canvas {
        id:           _hmc
        anchors.fill: parent

        Connections {
            target: root
            function onHeatDataChanged()  { _hmc.requestPaint() }
            function onWidthChanged()     { _hmc.requestPaint() }
            function onHeightChanged()    { _hmc.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var stride = root._stride
            var labW   = root._labW
            var labH   = root._labH
            var cs     = root.cellSize
            var col    = Qt.color(root.cellColor)
            var bg     = Qt.color(Theme.surfaceVariant)

            var now = new Date()
            // Start from 52 weeks ago, aligned to Sunday
            var start = new Date(now)
            start.setDate(start.getDate() - (root.weeks * 7 - 1))
            var dow = start.getDay()
            start.setDate(start.getDate() - dow)   // snap to Sunday

            var dayLabels = ["", "Mon", "", "Wed", "", "Fri", ""]

            // Day labels
            if (root.showDayLabels) {
                ctx.fillStyle   = Qt.color(Theme.textDisabled).toString()
                ctx.textAlign   = "right"; ctx.font = "8px '" + Theme.fontFamily + "'"
                for (var d = 0; d < 7; d++) {
                    if (dayLabels[d] !== "")
                        ctx.fillText(dayLabels[d], labW - 4, labH + d * stride + cs * 0.75)
                }
            }

            var lastMonth = -1
            for (var w = 0; w < root.weeks; w++) {
                for (var dd = 0; dd < 7; dd++) {
                    var date = new Date(start)
                    date.setDate(date.getDate() + w * 7 + dd)
                    if (date > now) continue

                    var key = date.getFullYear() + "-"
                              + String(date.getMonth() + 1).padStart(2, "0") + "-"
                              + String(date.getDate()).padStart(2, "0")
                    var val = root.heatData[key] || 0
                    var t   = Math.min(1, val / Math.max(1, root.maxValue))

                    var cx = labW + w * stride
                    var cy = labH + dd * stride

                    // Cell bg
                    ctx.fillStyle = Qt.rgba(bg.r, bg.g, bg.b, 1).toString()
                    ctx.fillRect(cx, cy, cs, cs)

                    // Fill
                    if (t > 0) {
                        ctx.fillStyle = Qt.rgba(col.r, col.g, col.b, 0.15 + t * 0.85).toString()
                        ctx.fillRect(cx, cy, cs, cs)
                    }

                    // Month label
                    if (root.showMonthLabels && dd === 0) {
                        var m = date.getMonth()
                        if (m !== lastMonth) {
                            lastMonth = m
                            var mNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
                            ctx.fillStyle   = Qt.color(Theme.textDisabled).toString()
                            ctx.textAlign   = "left"; ctx.font = "8px '" + Theme.fontFamily + "'"
                            ctx.fillText(mNames[m], cx, labH - 5)
                        }
                    }
                }
            }
        }
    }
}
