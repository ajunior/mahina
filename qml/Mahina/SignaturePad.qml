import QtQuick
import Mahina

// Canvas-based draw-to-sign input with clear button.
//
// Usage:
//   SignaturePad {
//       width: 400; height: 160
//       onSigned: console.log("Signed!")
//       onCleared: console.log("Cleared")
//   }
Item {
    id: root

    property color penColor:  Theme.textPrimary
    property real  penWidth:  2
    property bool  isEmpty:   true
    property string label:    "Sign here"

    signal signed()
    signal cleared()

    implicitWidth:  400
    implicitHeight: 160

    Rectangle {
        anchors.fill:  parent
        color:         Theme.surface
        radius:        Theme.radiusMd
        border.color:  Theme.border
        border.width:  1

        Canvas {
            id:           _pad
            anchors { fill: parent; margins: 1 }
            property real _lx: 0
            property real _ly: 0

            onPaint: {}   // incremental paint via requestPaint

            MouseArea {
                id:           _ma
                anchors.fill: parent
                hoverEnabled: true

                onPressed:  (m) => {
                    _pad._lx = m.x; _pad._ly = m.y
                    root.isEmpty = false
                }
                onPositionChanged: (m) => {
                    if (!pressed) return
                    var ctx = _pad.getContext("2d")
                    ctx.beginPath()
                    ctx.moveTo(_pad._lx, _pad._ly)
                    ctx.lineTo(m.x, m.y)
                    ctx.strokeStyle = root.penColor.toString()
                    ctx.lineWidth   = root.penWidth
                    ctx.lineCap     = "round"
                    ctx.lineJoin    = "round"
                    ctx.stroke()
                    _pad._lx = m.x; _pad._ly = m.y
                    root.signed()
                }
                cursorShape: Qt.CrossCursor
            }
        }

        // Placeholder label
        Text {
            visible:        root.isEmpty
            anchors.centerIn: parent
            text:           root.label
            color:          Theme.textDisabled
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textBase
        }

        // Baseline
        Rectangle {
            anchors { bottom: parent.bottom; bottomMargin: 28; left: parent.left; right: parent.right; leftMargin: Theme.sp4; rightMargin: Theme.sp4 }
            height: 1
            color: Theme.border
        }

        // Clear button
        Rectangle {
            anchors { top: parent.top; right: parent.right; topMargin: Theme.sp2; rightMargin: Theme.sp2 }
            visible:  !root.isEmpty
            width: 48; height: 22; radius: Theme.radiusSm
            color: Theme.panel

            Text {
                anchors.centerIn: parent
                text:           "Clear"
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var ctx = _pad.getContext("2d")
                    ctx.clearRect(0, 0, _pad.width, _pad.height)
                    root.isEmpty = true
                    root.cleared()
                }
            }
        }
    }
}
