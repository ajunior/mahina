import QtQuick
import Mahina

// Row of arc gauges for a dashboard cluster.
//
// Usage:
//   GaugeCluster {
//       gauges: [
//           { label: "CPU",     value: 72,  min: 0, max: 100, unit: "%", color: Theme.primary },
//           { label: "Memory",  value: 4.2, min: 0, max: 8,   unit: "GB",color: Theme.warning },
//           { label: "Network", value: 340, min: 0, max: 1000, unit: "MB",color: Theme.success },
//       ]
//   }
Item {
    id: root

    property var gauges: []
    property int gaugeSize: 100

    implicitWidth:  root.gauges.length * (root.gaugeSize + 16)
    implicitHeight: root.gaugeSize + 32

    Row {
        anchors.fill: parent
        spacing: 16

        Repeater {
            model: root.gauges
            delegate: Item {
                id: _rq1
                required property var  modelData
                width:  root.gaugeSize; height: root.gaugeSize + 32

                readonly property real gaugeMin: modelData.min || 0
                readonly property real gaugeMax: modelData.max || 100
                readonly property real gaugeVal: modelData.value || 0
                readonly property real normalised: Math.max(0, Math.min(1,
                    (gaugeVal - gaugeMin) / Math.max(gaugeMax - gaugeMin, 0.001)))

                Canvas {
                    id:     _gc
                    width:  root.gaugeSize; height: root.gaugeSize
                    anchors.horizontalCenter: parent.horizontalCenter

                    Connections {
                        target: root
                        function onGaugesChanged() { _gc.requestPaint() }
                    }

                    property real _target: parent.normalised
                    property real animNorm: 0
                    Behavior on animNorm { NumberAnimation { duration: 800; easing.type: Easing.OutCubic } }
                    on_TargetChanged: animNorm = _target
                    Component.onCompleted: { animNorm = _target; requestPaint() }
                    onAnimNormChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        var cx = width/2, cy = height*0.58, r = width*0.38
                        var startA = Math.PI * 0.75, endA = Math.PI * 2.25

                        // Track
                        ctx.strokeStyle = Qt.color(Theme.surfaceVariant).toString()
                        ctx.lineWidth   = 9; ctx.lineCap = "round"
                        ctx.beginPath(); ctx.arc(cx, cy, r, startA, endA); ctx.stroke()

                        // Fill
                        if (animNorm > 0) {
                            var fillEnd = startA + (endA - startA) * animNorm
                            var col = Qt.color(parent.modelData.color || Theme.primary)
                            ctx.strokeStyle = col.toString()
                            ctx.lineWidth   = 9; ctx.lineCap = "round"
                            ctx.beginPath(); ctx.arc(cx, cy, r, startA, fillEnd); ctx.stroke()
                        }

                        // Value text
                        ctx.fillStyle   = Qt.color(Theme.textPrimary).toString()
                        ctx.textAlign   = "center"; ctx.font = "bold 16px system-ui"
                        ctx.fillText(parent.gaugeVal.toFixed(parent.modelData.decimals || 0), cx, cy + 6)

                        // Unit
                        ctx.fillStyle   = Qt.color(Theme.textDisabled).toString()
                        ctx.font        = "10px system-ui"
                        ctx.fillText(parent.modelData.unit || "", cx, cy + 20)

                        // Min / Max ticks
                        ctx.fillStyle   = Qt.color(Theme.textDisabled).toString()
                        ctx.textAlign   = "center"; ctx.font = "9px system-ui"
                        var mnA = startA + 0.02
                        ctx.fillText((parent.modelData.min || 0).toString(),
                                     cx + (r+14)*Math.cos(mnA), cy + (r+14)*Math.sin(mnA))
                        var mxA = endA - 0.02
                        ctx.fillText((parent.modelData.max || 100).toString(),
                                     cx + (r+14)*Math.cos(mxA), cy + (r+14)*Math.sin(mxA))
                    }
                }

                Text {
                    anchors { top: _gc.bottom; horizontalCenter: parent.horizontalCenter }
                    text:           _rq1.modelData.label || ""
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    font.weight:    Font.Medium
                }
            }
        }
    }
}
