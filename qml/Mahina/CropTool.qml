pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Draggable crop-rectangle overlay. Place it over an image or any item.
//
// Usage:
//   Image { id: img; source: "photo.jpg" }
//   CropTool {
//       anchors.fill: img
//       onCropChanged: (r) => preview.cropRect = r  // normalized 0..1 rect
//   }
Item {
    id: root

    // Normalized crop rect (0..1 relative to item size)
    property real cropX:      0.1
    property real cropY:      0.1
    property real cropWidth:  0.8
    property real cropHeight: 0.8

    signal cropChanged(real x, real y, real w, real h)

    // Convert normalized to pixel coords
    readonly property real px: cropX * width
    readonly property real py: cropY * height
    readonly property real pw: cropWidth  * width
    readonly property real ph: cropHeight * height
    readonly property real minSize: 24

    // Dim areas outside crop
    Item {
        anchors.fill: parent

        // Top strip
        Rectangle { x:0; y:0; width: parent.width; height: root.py; color: Qt.rgba(0,0,0,0.45) }
        // Bottom strip
        Rectangle { x:0; y: root.py + root.ph; width: parent.width; height: parent.height - root.py - root.ph; color: Qt.rgba(0,0,0,0.45) }
        // Left strip (between top and bottom)
        Rectangle { x:0; y: root.py; width: root.px; height: root.ph; color: Qt.rgba(0,0,0,0.45) }
        // Right strip
        Rectangle { x: root.px + root.pw; y: root.py; width: parent.width - root.px - root.pw; height: root.ph; color: Qt.rgba(0,0,0,0.45) }

        // Crop border
        Rectangle {
            x: root.px; y: root.py; width: root.pw; height: root.ph
            color: "transparent"
            border.color: "white"
            border.width: 1.5

            // Rule-of-thirds grid
            Repeater {
                model: 2
                delegate: Rectangle {
                    required property int index
                    x: 0; y: (index + 1) * parent.height / 3
                    width: parent.width; height: 1
                    color: Qt.rgba(1,1,1,0.3)
                }
            }
            Repeater {
                model: 2
                delegate: Rectangle {
                    required property int index
                    x: (index + 1) * parent.width / 3
                    y: 0; width: 1; height: parent.height
                    color: Qt.rgba(1,1,1,0.3)
                }
            }
        }
    }

    // Move handle (center area)
    MouseArea {
        x: root.px + 16; y: root.py + 16
        width:  root.pw - 32
        height: root.ph - 32
        cursorShape: Qt.SizeAllCursor

        property real startX: 0; property real startY: 0
        property real startCX: 0; property real startCY: 0

        onPressed: (mouse) => {
            startX = mouse.x; startY = mouse.y
            startCX = root.cropX; startCY = root.cropY
        }
        onPositionChanged: (mouse) => {
            var dx = (mouse.x - startX) / root.width
            var dy = (mouse.y - startY) / root.height
            root.cropX = Math.max(0, Math.min(1 - root.cropWidth,  startCX + dx))
            root.cropY = Math.max(0, Math.min(1 - root.cropHeight, startCY + dy))
            root.cropChanged(root.cropX, root.cropY, root.cropWidth, root.cropHeight)
        }
    }

    // Corner handles
    Repeater {
        model: [
            { cursor: Qt.SizeFDiagCursor, dx: -1, dy: -1 },  // TL
            { cursor: Qt.SizeBDiagCursor, dx:  1, dy: -1 },  // TR
            { cursor: Qt.SizeBDiagCursor, dx: -1, dy:  1 },  // BL
            { cursor: Qt.SizeFDiagCursor, dx:  1, dy:  1 },  // BR
        ]

        delegate: Item {
            id: _rq1
            required property var modelData
            required property int index
            property int  dxSign: modelData.dx
            property int  dySign: modelData.dy
            property bool isRight:  dxSign > 0
            property bool isBottom: dySign > 0

            x: isRight  ? root.px + root.pw - 12 : root.px
            y: isBottom ? root.py + root.ph - 12 : root.py
            width: 24; height: 24

            Rectangle {
                width: 10; height: 10; color: "white"
                x: isRight  ? 14 : 0
                y: isBottom ? 14 : 0
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: _rq1.modelData.cursor

                property real startMX: 0; property real startMY: 0
                property real startCX: 0; property real startCY: 0
                property real startCW: 0; property real startCH: 0

                onPressed: (mouse) => {
                    startMX = mouse.x; startMY = mouse.y
                    startCX = root.cropX; startCY = root.cropY
                    startCW = root.cropWidth; startCH = root.cropHeight
                }
                onPositionChanged: (mouse) => {
                    var ddx = (mouse.x - startMX) / root.width
                    var ddy = (mouse.y - startMY) / root.height
                    if (dxSign < 0) {
                        var newW = Math.max(root.minSize/root.width, startCW - ddx)
                        root.cropX = Math.max(0, startCX + startCW - newW)
                        root.cropWidth = newW
                    } else {
                        root.cropWidth = Math.max(root.minSize/root.width, Math.min(1-root.cropX, startCW + ddx))
                    }
                    if (dySign < 0) {
                        var newH = Math.max(root.minSize/root.height, startCH - ddy)
                        root.cropY = Math.max(0, startCY + startCH - newH)
                        root.cropHeight = newH
                    } else {
                        root.cropHeight = Math.max(root.minSize/root.height, Math.min(1-root.cropY, startCH + ddy))
                    }
                    root.cropChanged(root.cropX, root.cropY, root.cropWidth, root.cropHeight)
                }
            }
        }
    }
}
