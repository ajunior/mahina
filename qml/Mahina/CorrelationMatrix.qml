import QtQuick
import Mahina

// Grid heatmap for pairwise correlation data (-1 to 1).
//
// Usage:
//   CorrelationMatrix {
//       matrixLabels: ["Temp","Rain","Wind","Humidity"]
//       matrixData:   [
//           [1.0,  -0.6, 0.3,  0.8],
//           [-0.6,  1.0, 0.1, -0.4],
//           [0.3,   0.1, 1.0,  0.2],
//           [0.8,  -0.4, 0.2,  1.0],
//       ]
//   }
Item {
    id: root

    property var    matrixLabels: []
    property var    matrixData:   []  // n×n 2D array, values -1..1
    property color  highColor:    Theme.primary
    property color  lowColor:     Theme.error
    property color  zeroColor:    Theme.surface

    signal cellClicked(int row, int col, real correlation)

    implicitWidth:  360
    implicitHeight: 360

    Canvas {
        id:           _cm
        anchors.fill: parent

        Connections {
            target: root
            function onMatrixDataChanged()   { _cm.requestPaint() }
            function onMatrixLabelsChanged() { _cm.requestPaint() }
            function onWidthChanged()        { _cm.requestPaint() }
            function onHeightChanged()       { _cm.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        function _lerp(a, b, t) {
            return { r: a.r + (b.r - a.r)*t, g: a.g + (b.g - a.g)*t, b: a.b + (b.b - a.b)*t }
        }
        function _cellColor(v) {
            var hi = Qt.color(root.highColor)
            var lo = Qt.color(root.lowColor)
            var zo = Qt.color(root.zeroColor)
            var c = (v >= 0) ? _lerp(zo, hi, v) : _lerp(zo, lo, -v)
            return Qt.rgba(c.r, c.g, c.b, 0.85).toString()
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var n = root.matrixLabels.length
            if (n === 0 || root.matrixData.length === 0) return

            var padL = 64, padT = 64, padR = 10, padB = 10
            var gridW = width  - padL - padR
            var gridH = height - padT - padB
            var cw = gridW / n, ch = gridH / n

            // Draw cells
            for (var r = 0; r < n; r++) {
                for (var c = 0; c < n; c++) {
                    var v = (root.matrixData[r] && root.matrixData[r][c] !== undefined)
                            ? root.matrixData[r][c] : 0
                    ctx.fillStyle = _cellColor(v)
                    ctx.fillRect(padL + c*cw, padT + r*ch, cw - 1, ch - 1)

                    // Value text
                    ctx.fillStyle = Math.abs(v) > 0.5 ? "rgba(255,255,255,0.9)" : Qt.color(Theme.textPrimary).toString()
                    ctx.textAlign = "center"; ctx.font = "bold " + Math.max(9, Math.min(13, cw*0.3)) + "px '" + Theme.fontFamily + "'"
                    ctx.fillText(v.toFixed(2), padL + c*cw + cw/2, padT + r*ch + ch/2 + 4)
                }
            }

            // Row labels (left)
            ctx.fillStyle = Qt.color(Theme.textSecondary).toString()
            ctx.textAlign  = "right"; ctx.font = "11px '" + Theme.fontFamily + "'"
            for (var ri = 0; ri < n; ri++)
                ctx.fillText(root.matrixLabels[ri] || "", padL - 6, padT + ri*ch + ch/2 + 4)

            // Column labels (top, rotated)
            ctx.fillStyle = Qt.color(Theme.textSecondary).toString()
            ctx.font = "11px '" + Theme.fontFamily + "'"; ctx.textAlign = "left"
            for (var ci = 0; ci < n; ci++) {
                ctx.save()
                ctx.translate(padL + ci*cw + cw/2, padT - 6)
                ctx.rotate(-Math.PI/4)
                ctx.fillText(root.matrixLabels[ci] || "", 0, 0)
                ctx.restore()
            }

            // Color scale (right side) — optional small gradient bar
        }

        // Click detection
        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => {
                var n = root.matrixLabels.length
                if (n === 0) return
                var padL = 64, padT = 64, padR = 10, padB = 10
                var gridW = width  - padL - padR
                var gridH = height - padT - padB
                var cw = gridW / n, ch = gridH / n
                var col = Math.floor((mouse.x - padL) / cw)
                var row = Math.floor((mouse.y - padT) / ch)
                if (row >= 0 && row < n && col >= 0 && col < n) {
                    var val = (root.matrixData[row] && root.matrixData[row][col] !== undefined)
                              ? root.matrixData[row][col] : 0
                    root.cellClicked(row, col, val)
                }
            }
        }
    }
}
