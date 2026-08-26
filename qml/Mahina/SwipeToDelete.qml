pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Swipe-left to reveal a delete (or custom action) button.
//
// Usage:
//   SwipeToDelete {
//       actionWidth: 80
//       actionColor: Theme.error
//       actionLabel: "Delete"
//       onActionTriggered: removeItem(index)
//       Rectangle { width: parent.width; height: 56; color: Theme.surface; ... }
//   }
Item {
    id: root

    property real   actionWidth:   80
    property color  actionColor:   Theme.error
    property string actionLabel:   "Delete"
    property string actionIcon:    ""

    signal actionTriggered()

    default property alias content: _contentItem.data

    implicitWidth:  400
    implicitHeight: _contentItem.implicitHeight || 56
    clip: true

    // How far the content has been swiped
    property real swipeOffset: 0

    Behavior on swipeOffset {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    // Action button revealed on the right
    Rectangle {
        anchors.right: parent.right
        width:  root.actionWidth
        height: parent.height
        color:  root.actionColor

        Column {
            anchors.centerIn: parent
            spacing: 2

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:           root.actionIcon
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textBase
                color:          Theme.textOnPrimary
                visible:        root.actionIcon !== ""
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:           root.actionLabel
                color:          Theme.textOnPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
                font.weight:    Font.Medium
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.swipeOffset = 0
                root.actionTriggered()
            }
        }
    }

    // Content layer
    Item {
        id:     _contentItem
        width:  parent.width
        height: parent.height
        x:      -root.swipeOffset
        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
    }

    // Swipe detector
    MouseArea {
        id:           _swipeMa
        anchors.fill: parent
        drag.axis:    Drag.XAxis
        drag.target:  null  // manual tracking
        preventStealing: true

        property real pressX: 0
        property real pressOffset: 0

        onPressed: (mouse) => {
            pressX      = mouse.x
            pressOffset = root.swipeOffset
        }
        onPositionChanged: (mouse) => {
            var delta = pressX - mouse.x
            root.swipeOffset = Math.max(0, Math.min(root.actionWidth, pressOffset + delta))
        }
        onReleased: (mouse) => {
            // Snap: if more than half revealed, snap open; else snap closed
            if (root.swipeOffset > root.actionWidth / 2)
                root.swipeOffset = root.actionWidth
            else
                root.swipeOffset = 0
        }
    }
}
