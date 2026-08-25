import QtQuick
import Mahina

// Animated ring countdown. Counts from `seconds` to 0 and emits `finished`.
//
// Usage:
//   CountdownTimer { seconds: 30; running: true; onFinished: doSomething() }
//   CountdownTimer { seconds: 60; size: 80; color: Theme.success; showLabel: true }
Item {
    id: root

    property int    seconds:    30
    property bool   running:    false
    property real   size:       64
    property color  color:      Theme.primary
    property color  trackColor: Theme.border
    property bool   showLabel:  true
    property real   strokeWidth: 5

    signal finished()
    signal tick(int remaining)

    implicitWidth:  size
    implicitHeight: size

    property int  _remaining: seconds
    property real fracLeft:   1.0

    onRunningChanged: {
        if (running) { _remaining = seconds; fracLeft = 1.0; _t.start() }
        else { _t.stop() }
    }
    onSecondsChanged: { _remaining = seconds; fracLeft = 1.0 }

    Timer {
        id:       _t
        interval: 1000
        repeat:   true
        onTriggered: {
            if (root._remaining <= 0) {
                stop(); root.finished(); return
            }
            root._remaining--
            root.fracLeft = root._remaining / root.seconds
            root.tick(root._remaining)
        }
    }

    Canvas {
        id:           _ring
        anchors.fill: parent

        Connections {
            target: root
            function onFracLeftChanged() { _ring.requestPaint() }
            function onColorChanged() { _ring.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx  = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var cx   = width / 2, cy = height / 2
            var r    = (Math.min(width, height) - root.strokeWidth) / 2

            // Track
            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, Math.PI * 2)
            ctx.strokeStyle = root.trackColor.toString()
            ctx.lineWidth   = root.strokeWidth
            ctx.stroke()

            // Progress arc
            var start = -Math.PI / 2
            var end   = start + root.fracLeft * Math.PI * 2
            ctx.beginPath()
            ctx.arc(cx, cy, r, start, end)
            ctx.strokeStyle = root.color.toString()
            ctx.lineWidth   = root.strokeWidth
            ctx.lineCap     = "round"
            ctx.stroke()
        }
    }

    Text {
        visible:        root.showLabel
        anchors.centerIn: parent
        text:           root._remaining
        color:          root.color
        font.family:    Theme.fontFamilyMono
        font.pixelSize: root.size * 0.28
        font.weight:    Theme.weightBold
    }
}
