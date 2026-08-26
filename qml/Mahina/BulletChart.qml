pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Bullet chart: compact progress bar with qualitative ranges and a target marker.
//
// Usage:
//   BulletChart {
//       items: [
//           { label: "Revenue",  value: 75, target: 80,
//             ranges: [{value:40,color:"#f87171"},{value:70,color:"#fbbf24"},{value:100,color:"#bbf7d0"}] },
//           { label: "Visitors", value: 4200, target: 5000,
//             ranges: [{value:2000,color:"#f87171"},{value:3500,color:"#fbbf24"},{value:6000,color:"#bbf7d0"}] },
//       ]
//       suffix: "%"
//   }
Item {
    id: root

    property var    items:    []
    property string suffix:   ""
    property real   rowHeight: 48

    implicitWidth:  360
    implicitHeight: Math.max(root.items.length, 1) * root.rowHeight

    Column {
        anchors.fill: parent

        Repeater {
            model: root.items
            delegate: Item {
                id: _rq1
                required property var modelData
                width:  root.width
                height: root.rowHeight

                readonly property real maxVal:   (function() {
                    var ranges = modelData.ranges || []
                    if (ranges.length === 0) return Math.max(modelData.value || 0, modelData.target || 0) * 1.2 || 1
                    var m = 0
                    for (var i = 0; i < ranges.length; i++) if (ranges[i].value > m) m = ranges[i].value
                    return m || 1
                })()

                readonly property real barLeft:   96
                readonly property real barRight:  16
                readonly property real barW:      width - barLeft - barRight
                readonly property real barH:      14
                readonly property real barY:      (rowHeight - barH) / 2

                Canvas {
                    id:           _bc
                    anchors.fill: parent

                    Connections {
                        target: root
                        function onItemsChanged(): void { _bc.requestPaint() }
                        function onWidthChanged(): void { _bc.requestPaint() }
                    }
                    Component.onCompleted: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)

                        var mx  = parent.maxVal
                        var bx  = parent.barLeft
                        var bw  = parent.barW
                        var by  = parent.barY
                        var bh  = parent.barH

                        // Background ranges (sorted ascending)
                        var ranges = (_rq1.modelData.ranges || []).slice()
                            .sort(function(a,b){ return b.value - a.value })
                        for (var ri = 0; ri < ranges.length; ri++) {
                            var rw = Math.min(ranges[ri].value / mx, 1) * bw
                            ctx.fillStyle = ranges[ri].color || "#ccc"
                            ctx.beginPath(); ctx.rect(bx, by, rw, bh); ctx.fill()
                        }
                        // Border around full range
                        ctx.strokeStyle = Qt.color(Theme.border).toString()
                        ctx.lineWidth   = 1
                        ctx.beginPath(); ctx.rect(bx, by, bw, bh); ctx.stroke()

                        // Value bar (darker, centered)
                        var vw = Math.min((_rq1.modelData.value || 0) / mx, 1) * bw
                        var vh = bh * 0.55
                        var vy = by + (bh - vh) / 2
                        ctx.fillStyle = Qt.color(Theme.textPrimary).toString()
                        ctx.beginPath(); ctx.rect(bx, vy, vw, vh); ctx.fill()

                        // Target marker
                        if (_rq1.modelData.target !== undefined) {
                            var tx = bx + Math.min((_rq1.modelData.target || 0) / mx, 1) * bw
                            ctx.strokeStyle = Qt.color(Theme.textPrimary).toString()
                            ctx.lineWidth   = 2.5
                            ctx.beginPath()
                            ctx.moveTo(tx, by - 2)
                            ctx.lineTo(tx, by + bh + 2)
                            ctx.stroke()
                        }

                        // Label
                        ctx.fillStyle   = Qt.color(Theme.textPrimary).toString()
                        ctx.textAlign   = "right"
                        ctx.font        = "11px '" + Theme.fontFamily + "'"
                        ctx.fillText(_rq1.modelData.label || "", bx - 8, by + bh/2 + 4)

                        // Value text
                        ctx.fillStyle   = Qt.color(Theme.textSecondary).toString()
                        ctx.textAlign   = "left"
                        ctx.font        = "10px '" + Theme.fontFamily + "'"
                        ctx.fillText((_rq1.modelData.value || 0) + root.suffix, bx + bw + 6, by + bh/2 + 4)
                    }
                }
            }
        }
    }
}
