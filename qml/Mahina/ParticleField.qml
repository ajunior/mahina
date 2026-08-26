pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Animated floating particle background using Canvas.
//
// Usage:
//   ParticleField {
//       anchors.fill: parent
//       particleCount: 60
//       particleColor: Theme.primary
//       speed: 0.8
//   }
Item {
    id: root

    property int   particleCount: 40
    property color particleColor: Theme.primary
    property real  speed:         1.0
    property real  maxRadius:     3.0
    property real  minRadius:     1.0
    property bool  connect:       true     // draw lines between nearby particles
    property real  connectDist:   100

    implicitWidth:  400
    implicitHeight: 300

    // Particle state (JS array, not QML model — faster)
    property var particles: []

    function _initParticles(): void {
        var pts = []
        for (var i = 0; i < root.particleCount; i++) {
            pts.push({
                x:   Math.random() * root.width,
                y:   Math.random() * root.height,
                vx:  (Math.random() - 0.5) * root.speed * 0.8,
                vy:  (Math.random() - 0.5) * root.speed * 0.8,
                r:   root.minRadius + Math.random() * (root.maxRadius - root.minRadius),
                o:   0.3 + Math.random() * 0.7
            })
        }
        root.particles = pts
    }

    function _step(): void {
        var pts = root.particles.slice()
        var w = root.width, h = root.height
        for (var i = 0; i < pts.length; i++) {
            pts[i].x += pts[i].vx
            pts[i].y += pts[i].vy
            if (pts[i].x < 0)   { pts[i].x = 0; pts[i].vx *= -1 }
            if (pts[i].x > w)   { pts[i].x = w; pts[i].vx *= -1 }
            if (pts[i].y < 0)   { pts[i].y = 0; pts[i].vy *= -1 }
            if (pts[i].y > h)   { pts[i].y = h; pts[i].vy *= -1 }
        }
        root.particles = pts
        _canvas.requestPaint()
    }

    Component.onCompleted: _initParticles()
    onWidthChanged:  _initParticles()
    onHeightChanged: _initParticles()
    onParticleCountChanged: _initParticles()

    Timer {
        interval: 30; repeat: true; running: root.visible
        onTriggered: root._step()
    }

    Canvas {
        id:           _canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var pts = root.particles
            if (!pts || pts.length === 0) return

            var bc = Qt.color(root.particleColor)
            var dist2 = root.connectDist * root.connectDist

            // Connection lines
            if (root.connect) {
                for (var i = 0; i < pts.length; i++) {
                    for (var j = i + 1; j < pts.length; j++) {
                        var dx = pts[i].x - pts[j].x
                        var dy = pts[i].y - pts[j].y
                        var d2 = dx*dx + dy*dy
                        if (d2 < dist2) {
                            var alpha = (1 - d2 / dist2) * 0.18
                            ctx.strokeStyle = Qt.rgba(bc.r, bc.g, bc.b, alpha).toString()
                            ctx.lineWidth   = 0.8
                            ctx.beginPath()
                            ctx.moveTo(pts[i].x, pts[i].y)
                            ctx.lineTo(pts[j].x, pts[j].y)
                            ctx.stroke()
                        }
                    }
                }
            }

            // Particles
            for (var pi = 0; pi < pts.length; pi++) {
                ctx.beginPath()
                ctx.arc(pts[pi].x, pts[pi].y, pts[pi].r, 0, Math.PI*2)
                ctx.fillStyle = Qt.rgba(bc.r, bc.g, bc.b, pts[pi].o).toString()
                ctx.fill()
            }
        }
    }
}
