pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Before/after image comparison with a draggable divider.
//
// Usage:
//   ImageComparison {
//       beforeSrc: "qrc:/before.jpg"
//       afterSrc:  "qrc:/after.jpg"
//       splitPos:  0.5   // 0..1
//       beforeLabel: "Original"
//       afterLabel:  "Enhanced"
//   }
Rectangle {
    id: root

    property string beforeSrc:    ""
    property string afterSrc:     ""
    property real   splitPos:     0.5
    property string beforeLabel:  "Before"
    property string afterLabel:   "After"

    implicitWidth:  480
    implicitHeight: 280

    color:  "#111"; clip: true
    radius: Theme.radiusMd

    // "After" image (full width, underneath)
    Image {
        anchors.fill: parent
        source:   root.afterSrc
        fillMode: Image.PreserveAspectCrop
    }

    // "Before" image (clipped to left of splitPos)
    Item {
        width: root.width * root.splitPos; height: root.height; clip: true
        Image {
            width:  root.width; height: root.height
            source: root.beforeSrc
            fillMode: Image.PreserveAspectCrop
        }
    }

    // Divider line
    Rectangle {
        x:     root.width * root.splitPos - 1
        width: 2; height: root.height
        color: "white"
        opacity: 0.85

        // Handle knob
        Rectangle {
            anchors.centerIn: parent
            width: 32; height: 32; radius: 16
            color: "white"
            Row {
                anchors.centerIn: parent; spacing: 3
                Text { text: "◀"; font.pixelSize: 8; color: "#333" }
                Text { text: "▶"; font.pixelSize: 8; color: "#333" }
            }
        }
    }

    // Labels
    Rectangle {
        anchors { left: parent.left; top: parent.top; margins: 10 }
        width: _beforeLbl.implicitWidth + 12; height: 22; radius: 11
        color: Qt.rgba(0,0,0,0.5)
        Text { id: _beforeLbl; anchors.centerIn: parent; text: root.beforeLabel; color: "white"; font.pixelSize: Theme.textXs; font.weight: Font.Medium; font.family: Theme.fontFamily }
    }

    Rectangle {
        anchors { right: parent.right; top: parent.top; margins: 10 }
        width: _afterLbl.implicitWidth + 12; height: 22; radius: 11
        color: Qt.rgba(0,0,0,0.5)
        Text { id: _afterLbl; anchors.centerIn: parent; text: root.afterLabel; color: "white"; font.pixelSize: Theme.textXs; font.weight: Font.Medium; font.family: Theme.fontFamily }
    }

    // Drag handler
    MouseArea {
        anchors.fill: parent; cursorShape: Qt.SizeHorCursor
        onPositionChanged: (mouse) => {
            root.splitPos = Math.max(0.02, Math.min(0.98, mouse.x / root.width))
        }
    }
}
