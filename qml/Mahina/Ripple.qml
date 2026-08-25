import QtQuick
import Mahina

// Material-style click ripple wrapper. Place content inside as children.
//
// Usage:
//   Ripple {
//       width: 120; height: 40
//       radius: Theme.radiusMd
//       Rectangle { anchors.fill: parent; color: Theme.panel; radius: parent.radius }
//       Text { anchors.centerIn: parent; text: "Click me" }
//       onClicked: doSomething()
//   }
Item {
    id: root

    property real  radius:     0
    property color rippleColor: Qt.rgba(1, 1, 1, 0.25)

    signal clicked()

    default property alias content: _contentItem.data

    clip: true

    Item { id: _contentItem; anchors.fill: parent }

    Canvas {
        id:           _rippleCanvas
        anchors.fill: parent
        property real rX:   0
        property real rY:   0
        property real rRad: 0
        property real rOpa: 0

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            if (rRad <= 0) return
            var c = Qt.color(root.rippleColor)
            ctx.beginPath()
            ctx.arc(rX, rY, rRad, 0, Math.PI * 2)
            ctx.fillStyle = Qt.rgba(c.r, c.g, c.b, rOpa).toString()
            ctx.fill()
        }

        onRRadChanged: requestPaint()
        onROpaChanged: requestPaint()
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor

        onPressed: (mouse) => {
            _rippleCanvas.rX   = mouse.x
            _rippleCanvas.rY   = mouse.y
            _rippleCanvas.rRad = 0
            _rippleCanvas.rOpa = 0.5
            _rippleExpand.start()
        }

        onClicked: root.clicked()
    }

    ParallelAnimation {
        id: _rippleExpand
        NumberAnimation {
            target:   _rippleCanvas
            property: "rRad"
            from:     0
            to:       Math.sqrt(root.width * root.width + root.height * root.height)
            duration: 450
            easing.type: Easing.OutQuad
        }
        SequentialAnimation {
            PauseAnimation { duration: 200 }
            NumberAnimation {
                target:   _rippleCanvas
                property: "rOpa"
                to:       0
                duration: 250
            }
        }
    }
}
