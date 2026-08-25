import QtQuick
import Mahina

// Pinch-to-zoom and drag-to-pan wrapper. Place any item inside as content.
//
// Usage:
//   ZoomPan {
//       width: 600; height: 400
//       Image { source: "large-map.png"; width: 1200; height: 800 }
//   }
//   ZoomPan { zoomLevel: 2.0; onZoomLevelChanged: (z) => label.text = z.toFixed(1) + "x" }
Item {
    id: root

    default property alias content: _inner.children

    property real zoomLevel: 1.0
    property real minZoom:   0.1
    property real maxZoom:   8.0
    property real panX:      0
    property real panY:      0
    property bool showControls: true

    clip: true

    Item {
        id: _inner
        width:  root.width
        height: root.height
        transformOrigin: Item.TopLeft
        transform: [
            Scale     { xScale: root.zoomLevel; yScale: root.zoomLevel },
            Translate { x: root.panX; y: root.panY }
        ]
    }

    // Scroll-wheel zoom
    WheelHandler {
        id:         _wheel
        target:     null
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

        onWheel: (event) => {
            var factor = event.angleDelta.y > 0 ? 1.12 : 1 / 1.12
            var newZ   = Math.max(root.minZoom, Math.min(root.maxZoom, root.zoomLevel * factor))
            // Zoom around mouse position
            var mx = event.position.x, my = event.position.y
            root.panX  = mx + (root.panX - mx) * (newZ / root.zoomLevel)
            root.panY  = my + (root.panY - my) * (newZ / root.zoomLevel)
            root.zoomLevel = newZ
        }
    }

    // Drag to pan
    MouseArea {
        id:          _pan
        anchors.fill: parent
        cursorShape:  pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        propagateComposedEvents: true

        property real startX: 0; property real startY: 0
        property real startPX: 0; property real startPY: 0

        onPressed: (mouse) => {
            startX  = mouse.x; startY  = mouse.y
            startPX = root.panX; startPY = root.panY
        }
        onPositionChanged: (mouse) => {
            root.panX = startPX + (mouse.x - startX)
            root.panY = startPY + (mouse.y - startY)
        }
    }

    // Controls overlay
    Item {
        visible:    root.showControls
        anchors {
            right:        parent.right
            bottom:       parent.bottom
            rightMargin:  Theme.sp3
            bottomMargin: Theme.sp3
        }
        width:  96
        height: 28

        Rectangle {
            anchors.fill: parent
            radius:  Theme.radiusMd
            color:   Qt.rgba(Qt.color(Theme.surface).r, Qt.color(Theme.surface).g, Qt.color(Theme.surface).b, 0.9)
            border.color: Theme.border; border.width: 1

            Row {
                anchors { fill: parent; margins: 2 }
                spacing: 2

                Repeater {
                    model: ["-", "⌂", "+"]
                    delegate: Rectangle {
                        id: _rq1
                        required property string modelData
                        width:  (parent.width - 4) / 3
                        height: parent.height
                        radius: Theme.radiusSm
                        color:  _btnH.containsMouse ? Theme.panel : "transparent"
                        HoverHandler { id: _btnH }
                        Text {
                            anchors.centerIn: parent
                            text:  _rq1.modelData
                            color: Theme.textSecondary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: {
                                if (_rq1.modelData === "+") root.zoomLevel = Math.min(root.maxZoom, root.zoomLevel * 1.25)
                                else if (_rq1.modelData === "-") root.zoomLevel = Math.max(root.minZoom, root.zoomLevel / 1.25)
                                else { root.zoomLevel = 1.0; root.panX = 0; root.panY = 0 }
                            }
                        }
                    }
                }
            }
        }
    }

    // Zoom level badge
    Text {
        visible: root.showControls
        anchors {
            left:         parent.left
            bottom:       parent.bottom
            leftMargin:   Theme.sp3
            bottomMargin: Theme.sp3
        }
        text:  root.zoomLevel.toFixed(1) + "×"
        color: Theme.textDisabled
        font.family:    Theme.fontFamilyMono
        font.pixelSize: Theme.textXs
    }
}
