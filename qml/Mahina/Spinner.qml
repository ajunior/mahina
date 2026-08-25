import QtQuick
import Mahina

// Circular loading spinner drawn with Canvas.
//
// Usage:
//   Spinner {}
//   Spinner { size: 32; color: Theme.success }
//   Spinner { size: 20; speed: 600 }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property color color: Theme.primary
    property real  size:  24
    property int   speed: 900    // ms per full rotation

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  root.size
    implicitHeight: root.size

    // ── Canvas ────────────────────────────────────────────────────────────────
    Canvas {
        id:           _canvas
        anchors.fill: parent

        // Stroke width scales proportionally with size
        readonly property real sw: Math.max(1.5, root.size * 0.1)

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var cx = width  / 2
            var cy = height / 2
            var r  = (Math.min(width, height) / 2) - sw / 2 - 0.5

            // Ghost track
            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, Math.PI * 2)
            ctx.strokeStyle = Qt.rgba(root.color.r, root.color.g, root.color.b, 0.15)
            ctx.lineWidth   = sw
            ctx.stroke()

            // 270° arc — static in canvas-local space; parent rotation spins it
            ctx.beginPath()
            ctx.arc(cx, cy, r, -Math.PI / 2, Math.PI)
            ctx.strokeStyle = root.color.toString()
            ctx.lineWidth   = sw
            ctx.lineCap     = "round"
            ctx.stroke()
        }

        // Repaint when color or stroke width changes
        onSwChanged: requestPaint()
        Connections {
            target: root
            function onColorChanged() { _canvas.requestPaint() }
            function onSizeChanged()  { _canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }

    // ── Rotation ──────────────────────────────────────────────────────────────
    RotationAnimator {
        target:       _canvas
        from:         0
        to:           360
        duration:     root.speed
        loops:        Animation.Infinite
        running:      root.visible
        easing.type:  Easing.Linear
    }
}
