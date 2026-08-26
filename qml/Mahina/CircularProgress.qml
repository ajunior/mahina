pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Ring progress indicator. Complement to the linear ProgressBar.
//
// Usage:
//   CircularProgress { value: 0.75 }
//   CircularProgress { value: 0.4; size: 64; strokeWidth: 6; showValue: true }
//   CircularProgress { indeterminate: true; size: 24 }
//   CircularProgress { value: 0.9; color: Theme.success; trackColor: Theme.successSubtle }
Item {
    id: root

    property real   value:         0.0     // 0.0 – 1.0
    property real   size:          48
    property real   strokeWidth:   5
    property color  color:         Theme.primary
    property color  trackColor:    Theme.border
    property bool   indeterminate: false
    property bool   showValue:     false
    property int    decimals:      0

    implicitWidth:  root.size
    implicitHeight: root.size
    width:          root.size
    height:         root.size

    // Arc-length fraction oscillates while indeterminate
    property real arcFrac: 0.25
    SequentialAnimation on arcFrac {
        running:  root.indeterminate
        loops:    Animation.Infinite
        NumberAnimation { from: 0.15; to: 0.75; duration: 800; easing.type: Easing.InOutSine }
        NumberAnimation { from: 0.75; to: 0.15; duration: 800; easing.type: Easing.InOutSine }
    }

    Canvas {
        id:           _canvas
        anchors.fill: parent

        // Rotate the whole canvas for the indeterminate spin
        RotationAnimator on rotation {
            running:  root.indeterminate
            from:     0; to: 360
            duration: 1000
            loops:    Animation.Infinite
        }

        // Repaint on value/style changes
        Connections {
            target: root
            function onValueChanged(): void { _canvas.requestPaint() }
            function onColorChanged(): void { _canvas.requestPaint() }
            function onTrackColorChanged(): void { _canvas.requestPaint() }
            function onStrokeWidthChanged(): void { _canvas.requestPaint() }
            function onArcFracChanged(): void { _canvas.requestPaint() }
            function onIndeterminateChanged(): void { _canvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var cx = width  / 2
            var cy = height / 2
            var r  = (Math.min(width, height) - root.strokeWidth) / 2

            // Track ring
            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, Math.PI * 2)
            ctx.strokeStyle = root.trackColor.toString()
            ctx.lineWidth   = root.strokeWidth
            ctx.stroke()

            // Progress arc (always from top; canvas rotates for indeterminate)
            var arcEnd = root.indeterminate
                         ? (root.arcFrac * Math.PI * 2)
                         : (root.value   * Math.PI * 2)

            if (arcEnd > 0) {
                ctx.beginPath()
                ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + arcEnd)
                ctx.strokeStyle = root.color.toString()
                ctx.lineWidth   = root.strokeWidth
                ctx.lineCap     = "round"
                ctx.stroke()
            }
        }
    }

    // Optional value label (only meaningful for determinate mode)
    Text {
        visible:          root.showValue && !root.indeterminate
        anchors.centerIn: parent
        text:             (root.value * 100).toFixed(root.decimals) + "%"
        color:            Theme.textPrimary
        font.family:      Theme.fontFamily
        font.pixelSize:   root.size * 0.22
        font.weight:      Theme.weightSemibold
    }
}
