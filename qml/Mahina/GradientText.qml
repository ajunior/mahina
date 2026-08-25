import QtQuick
import Mahina

// Text rendered with a horizontal gradient fill via Canvas.
//
// Usage:
//   GradientText {
//       displayText: "Hello, Mahina!"
//       fontSize:    48
//       gradientStops: [
//           { pos: 0.0, color: "#6366f1" },
//           { pos: 0.5, color: "#a855f7" },
//           { pos: 1.0, color: "#ec4899" },
//       ]
//   }
Item {
    id: root

    property string displayText:  "Gradient"
    property real   fontSize:     32
    property string fontFamily:   Theme.fontFamily
    property int    fontWeight:   Font.Bold
    property var    gradientStops: [
        { pos: 0.0, color: Theme.primary },
        { pos: 1.0, color: Theme.error   }
    ]

    // Size from a hidden measuring Text
    implicitWidth:  _measure.implicitWidth
    implicitHeight: _measure.implicitHeight

    Text {
        id:             _measure
        visible:        false
        text:           root.displayText
        font.pixelSize: root.fontSize
        font.family:    root.fontFamily
        font.weight:    root.fontWeight
    }

    Canvas {
        id:           _canvas
        anchors.fill: parent

        Connections {
            target: root
            function onDisplayTextChanged()   { _canvas.requestPaint() }
            function onFontSizeChanged()      { _canvas.requestPaint() }
            function onGradientStopsChanged() { _canvas.requestPaint() }
            function onWidthChanged()         { _canvas.requestPaint() }
            function onHeightChanged()        { _canvas.requestPaint() }
        }
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var fontStr = root.fontWeight >= Font.Bold ? "bold " : ""
            fontStr += root.fontSize + "px "
            fontStr += "'" + (root.fontFamily || "system-ui") + "'"
            ctx.font = fontStr

            var grad = ctx.createLinearGradient(0, 0, width, 0)
            var stops = root.gradientStops
            for (var i = 0; i < stops.length; i++) {
                try {
                    var c = stops[i].color
                    // Handle both hex strings and Qt color objects
                    var cStr = (typeof c === "string") ? c : Qt.color(c).toString()
                    grad.addColorStop(stops[i].pos, cStr)
                } catch(e) {}
            }

            ctx.fillStyle   = grad
            ctx.textBaseline = "middle"
            ctx.textAlign    = "left"
            ctx.fillText(root.displayText, 0, height / 2)
        }
    }
}
