import QtQuick
import Mahina

// Half-circle gauge — ideal for dashboards (speed, load, score).
// Sweeps 270° from bottom-left through the top to bottom-right.
//
// Usage:
//   Gauge { value: 0.72; size: 160 }
//   Gauge { value: 0.9; color: Theme.success; label: "Uptime"; unit: "%" }
//   Gauge { value: 0.45; min: 0; max: 200; unit: " rpm"; showValue: true }
Item {
    id: root

    property real   value:       0.0      // 0.0 – 1.0
    property real   min:         0
    property real   max:         100
    property real   size:        160
    property real   strokeWidth: 12
    property color  color:       Theme.primary
    property color  trackColor:  Theme.border
    property string label:       ""
    property string unit:        ""
    property bool   showValue:   true
    property int    decimals:    0

    implicitWidth:  root.size
    implicitHeight: root.size * 0.75   // half-circle + some room

    // Ticks (optional)
    property int    ticks:       5       // 0 = no ticks

    // ── Arc constants ─────────────────────────────────────────────────────────
    // Start: 225° (bottom-left), End: 315° (bottom-right), sweep 270° counterclockwise
    readonly property real _startRad: 225 * Math.PI / 180
    readonly property real _sweepRad: 270 * Math.PI / 180

    Canvas {
        id:           _canvas
        width:        root.size
        height:       root.size
        anchors.top:  parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        Connections {
            target: root
            function onValueChanged()      { _canvas.requestPaint() }
            function onColorChanged()      { _canvas.requestPaint() }
            function onTrackColorChanged() { _canvas.requestPaint() }
            function onStrokeWidthChanged(){ _canvas.requestPaint() }
            function onSizeChanged()       { _canvas.requestPaint() }
            function onTicksChanged()      { _canvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var cx    = width  / 2
            var cy    = height / 2
            var r     = (Math.min(width, height) - root.strokeWidth) / 2

            var startA = root._startRad
            var endA   = startA - root._sweepRad   // counterclockwise: decreasing angle

            // Track arc (counterclockwise from 225° to 315°)
            ctx.beginPath()
            ctx.arc(cx, cy, r, startA, endA, true)
            ctx.strokeStyle = root.trackColor.toString()
            ctx.lineWidth   = root.strokeWidth
            ctx.lineCap     = "round"
            ctx.stroke()

            // Progress arc
            if (root.value > 0) {
                var progressEnd = startA - root.value * root._sweepRad
                ctx.beginPath()
                ctx.arc(cx, cy, r, startA, progressEnd, true)
                ctx.strokeStyle = root.color.toString()
                ctx.lineWidth   = root.strokeWidth
                ctx.lineCap     = "round"
                ctx.stroke()
            }

            // Tick marks
            if (root.ticks > 1) {
                var tickR  = r + root.strokeWidth * 0.7
                var tickLen= root.strokeWidth * 0.5
                for (var i = 0; i <= root.ticks; i++) {
                    var a = startA - (i / root.ticks) * root._sweepRad
                    var x1 = cx + tickR * Math.cos(a)
                    var y1 = cy + tickR * Math.sin(a)
                    var x2 = cx + (tickR + tickLen) * Math.cos(a)
                    var y2 = cy + (tickR + tickLen) * Math.sin(a)
                    ctx.beginPath()
                    ctx.moveTo(x1, y1)
                    ctx.lineTo(x2, y2)
                    ctx.strokeStyle = root.trackColor.toString()
                    ctx.lineWidth   = 1.5
                    ctx.stroke()
                }
            }
        }
    }

    // Value label
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:              parent.top
        anchors.topMargin:        root.size * 0.52
        spacing:                  2

        Text {
            visible:          root.showValue
            anchors.horizontalCenter: parent.horizontalCenter
            text:             (root.min + root.value * (root.max - root.min)).toFixed(root.decimals) + root.unit
            color:            Theme.textPrimary
            font.family:      Theme.fontFamily
            font.pixelSize:   root.size * 0.18
            font.weight:      Theme.weightBold
        }

        Text {
            visible:          root.label !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            text:             root.label
            color:            Theme.textSecondary
            font.family:      Theme.fontFamily
            font.pixelSize:   root.size * 0.1
            font.weight:      Theme.weightMedium
        }
    }

    // Min/max labels
    Text {
        anchors { bottom: parent.bottom; left: parent.left; leftMargin: root.strokeWidth }
        text:           root.min.toFixed(0)
        color:          Theme.textDisabled
        font.family:    Theme.fontFamily
        font.pixelSize: root.size * 0.08
    }
    Text {
        anchors { bottom: parent.bottom; right: parent.right; rightMargin: root.strokeWidth }
        text:           root.max.toFixed(0)
        color:          Theme.textDisabled
        font.family:    Theme.fontFamily
        font.pixelSize: root.size * 0.08
    }
}
