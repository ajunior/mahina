pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Gradient editor with draggable color stops.
//
// Usage:
//   ColorGradientPicker {
//       stops: [
//           { pos: 0.0, color: "#6366f1" },
//           { pos: 0.5, color: "#a855f7" },
//           { pos: 1.0, color: "#ec4899" },
//       ]
//       onStopsEdited: (stops) => applyGradient(stops)
//   }
Item {
    id: root

    // stops: [{pos: 0..1, color: string}]
    property var stops: [{ pos: 0.0, color: "#6366f1" }, { pos: 1.0, color: "#ec4899" }]
    property int activeStop: 0

    signal stopsEdited(var stops)

    implicitWidth:  360
    implicitHeight: 120

    // Gradient preview bar height
    readonly property int barH:    28
    readonly property int barY:    40
    readonly property int barOff:  16  // horizontal padding so stops don't clip

    // Build gradient string for Canvas
    function _gradientCss() {
        var sorted = root.stops.slice().sort(function(a,b) { return a.pos - b.pos })
        return sorted
    }

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onStopsChanged()  { _canvas.requestPaint() }
            function onWidthChanged()  { _canvas.requestPaint() }
            function onHeightChanged() { _canvas.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx  = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var bx = root.barOff
            var bw = width - root.barOff * 2
            var by = root.barY
            var bh = root.barH

            // Checkerboard for transparency indication
            var tileSize = 8
            for (var tx = 0; tx < bw; tx += tileSize) {
                for (var ty = 0; ty < bh; ty += tileSize) {
                    var alt = ((Math.floor(tx/tileSize) + Math.floor(ty/tileSize)) % 2) === 0
                    ctx.fillStyle = alt ? "#ccc" : "#fff"
                    ctx.fillRect(bx + tx, by + ty, Math.min(tileSize, bw-tx), Math.min(tileSize, bh-ty))
                }
            }

            // Gradient
            var sorted = root.stops.slice().sort(function(a,b){return a.pos-b.pos})
            var grad = ctx.createLinearGradient(bx, 0, bx + bw, 0)
            for (var i = 0; i < sorted.length; i++) {
                try { grad.addColorStop(sorted[i].pos, sorted[i].color) } catch(e) {}
            }
            ctx.fillStyle = grad
            ctx.beginPath()
            ctx.rect(bx, by, bw, bh)
            ctx.fill()

            // Border
            ctx.strokeStyle = Qt.color(Theme.border).toString()
            ctx.lineWidth   = 1
            ctx.beginPath(); ctx.rect(bx, by, bw, bh); ctx.stroke()

            // Stop handles (drawn below bar)
            for (var si = 0; si < root.stops.length; si++) {
                var st  = root.stops[si]
                var sx  = bx + st.pos * bw
                var sy  = by + bh + 4

                // Triangle pointer
                ctx.fillStyle = si === root.activeStop ? Theme.textPrimary.toString() : Theme.textSecondary.toString()
                ctx.beginPath()
                ctx.moveTo(sx - 6, sy)
                ctx.lineTo(sx + 6, sy)
                ctx.lineTo(sx, sy - 5)
                ctx.closePath()
                ctx.fill()

                // Color dot
                ctx.fillStyle = st.color || "#000"
                ctx.beginPath(); ctx.arc(sx, sy + 10, 6, 0, Math.PI*2); ctx.fill()
                ctx.strokeStyle = si === root.activeStop
                    ? Qt.color(Theme.primary).toString()
                    : Qt.color(Theme.border).toString()
                ctx.lineWidth = si === root.activeStop ? 2 : 1
                ctx.stroke()
            }
        }

        // Click on bar to add stop; click on handle to select it
        MouseArea {
            anchors.fill: parent
            property int  dragStopIdx: -1
            property bool isDragging: false

            onPressed: (mouse) => {
                var bx  = root.barOff
                var bw  = width - root.barOff * 2
                var by  = root.barY
                var bh  = root.barH

                // Check if clicking a stop handle
                for (var si = 0; si < root.stops.length; si++) {
                    var hx = bx + root.stops[si].pos * bw
                    var hy = by + bh + 10
                    if (Math.abs(mouse.x - hx) < 10 && Math.abs(mouse.y - hy) < 16) {
                        root.activeStop = si
                        isDragging = true
                        dragStopIdx = si
                        return
                    }
                }

                // Click on gradient bar adds new stop
                if (mouse.y >= by && mouse.y <= by + bh) {
                    var pos = Math.max(0, Math.min(1, (mouse.x - bx) / bw))
                    var newStops = root.stops.slice()
                    newStops.push({ pos: pos, color: Qt.color(Theme.primary).toString() })
                    root.stops = newStops
                    root.activeStop = newStops.length - 1
                    root.stopsEdited(root.stops)
                }
            }

            onPositionChanged: (mouse) => {
                if (!isDragging || dragStopIdx < 0) return
                var bx = root.barOff
                var bw = width - root.barOff * 2
                var pos = Math.max(0, Math.min(1, (mouse.x - bx) / bw))
                var newStops = root.stops.slice()
                newStops[dragStopIdx] = { pos: pos, color: newStops[dragStopIdx].color }
                root.stops = newStops
                root.stopsEdited(root.stops)
            }

            onReleased: { isDragging = false; dragStopIdx = -1 }
        }
    }

    // Info row
    Row {
        anchors { left: parent.left; right: parent.right; leftMargin: root.barOff; top: parent.top }
        height: root.barY
        spacing: Theme.sp3

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text:  root.stops.length + " stops"
            color: Theme.textDisabled
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
        }

        // Active stop color display
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 20; height: 20; radius: 4
            color: root.activeStop < root.stops.length ? root.stops[root.activeStop].color : "transparent"
            border.color: Theme.border; border.width: 1
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text:  root.activeStop < root.stops.length ? root.stops[root.activeStop].color : ""
            color: Theme.textSecondary
            font.family:    Theme.fontFamilyMono
            font.pixelSize: Theme.textXs
        }
    }
}
