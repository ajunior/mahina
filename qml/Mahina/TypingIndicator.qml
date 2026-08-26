pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Animated "someone is typing" indicator with bouncing dots.
//
// Usage:
//   TypingIndicator {
//       typing:   true
//       username: "Alice"    // optional — shows "Alice is typing…"
//   }
Item {
    id: root

    property bool   typing:   false
    property string username: ""
    property color  dotColor: Theme.textSecondary
    property real   dotSize:  8

    implicitWidth:  _row.implicitWidth
    implicitHeight: _row.implicitHeight

    Row {
        id:     _row
        spacing: Theme.sp2
        visible: root.typing

        // Three bouncing dots
        Repeater {
            model: 3
            delegate: Rectangle {
                id: _rq1
                required property int index
                width:  root.dotSize; height: root.dotSize; radius: root.dotSize / 2
                color:  root.dotColor

                SequentialAnimation on y {
                    loops:   Animation.Infinite
                    running: root.typing
                    PauseAnimation        { duration: _rq1.index * 120 }
                    NumberAnimation { to: -5;  duration: 240; easing.type: Easing.OutQuad }
                    NumberAnimation { to:  0;  duration: 240; easing.type: Easing.InQuad  }
                    PauseAnimation        { duration: (2 - _rq1.index) * 120 + 200 }
                }
            }
        }

        // "X is typing…" label
        Text {
            visible:        root.username !== ""
            anchors.verticalCenter: parent.verticalCenter
            text:           root.username + " is typing…"
            color:          Theme.textDisabled
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            font.italic:    true
        }
    }

    // Invisible placeholder to hold space when not typing
    Item {
        visible: !root.typing
        width:   _row.implicitWidth || 40
        height:  _row.implicitHeight || root.dotSize
    }
}
