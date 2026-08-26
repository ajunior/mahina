pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Canvas confetti burst animation. Invisible until burst() is called.
//
// Usage:
//   Confetti { id: _confetti; anchors.fill: parent; z: 9999 }
//   Button { text: "Celebrate!"; onClicked: _confetti.burst() }
//
// Place as full-size overlay over the content area.
Item {
    id: root

    property int count:    80
    property var colors:   ["#f38ba8","#a6e3a1","#89b4fa","#f9e2af","#cba6f7","#74c7ec","#fab387","#a6da95"]
    property int gravity:  4    // 1=floaty, 10=heavy

    visible: false

    function burst() {
        root.visible = true
        _parts = []
        for (var i = 0; i < root.count; i++) {
            _parts.push({
                x:     root.width  * (0.25 + Math.random() * 0.5),
                y:     root.height * 0.25,
                vx:    (Math.random() - 0.5) * 10,
                vy:    -(Math.random() * 8 + 3),
                vr:    (Math.random() - 0.5) * 0.25,
                rot:   Math.random() * Math.PI * 2,
                w:     5 + Math.random() * 7,
                h:     3 + Math.random() * 4,
                color: root.colors[Math.floor(Math.random() * root.colors.length)],
                life:  1.0
            })
        }
        _ticker.start()
    }

    property var _parts: []

    Canvas {
        id:           _canvas
        anchors.fill: parent

        onPaint: {
            var ctx   = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var alive = false
            var g     = root.gravity * 0.05

            for (var i = 0; i < root._parts.length; i++) {
                var p = root._parts[i]
                if (p.life <= 0) continue
                alive = true

                ctx.save()
                ctx.globalAlpha = Math.min(1, p.life * 2)
                ctx.translate(p.x, p.y)
                ctx.rotate(p.rot)
                ctx.fillStyle = p.color
                ctx.fillRect(-p.w / 2, -p.h / 2, p.w, p.h)
                ctx.restore()

                p.vy  += g
                p.x   += p.vx
                p.y   += p.vy
                p.rot += p.vr
                p.life -= 0.008
            }

            if (!alive) {
                root.visible = false
                _ticker.stop()
            }
        }
    }

    Timer {
        id:       _ticker
        interval: 16
        repeat:   true
        onTriggered: _canvas.requestPaint()
    }
}
