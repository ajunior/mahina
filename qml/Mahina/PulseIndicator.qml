pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Pulsing status dot for live / online / recording indicators.
//
// Usage:
//   PulseIndicator { status: "online"    }   // green with pulse
//   PulseIndicator { status: "recording" }   // red with pulse
//   PulseIndicator { status: "away"      }   // yellow, static
//   PulseIndicator { status: "offline"   }   // grey, static
//   PulseIndicator { size: 16; showLabel: true }
Item {
    id: root

    property string status:    "online"   // "online" | "away" | "offline" | "recording"
    property real   size:      10
    property bool   showLabel: false

    implicitWidth:  showLabel ? _dot.width + Theme.sp2 + _lbl.implicitWidth : size
    implicitHeight: size

    readonly property color dotColor: {
        switch (status) {
        case "online":    return Theme.success
        case "away":      return Theme.warning
        case "recording": return Theme.error
        default:          return Theme.textDisabled
        }
    }

    readonly property bool pulsing: status === "online" || status === "recording"

    // Outer pulse ring
    Rectangle {
        id:      _ring
        visible: root.pulsing
        width:   root.size * 2.4
        height:  root.size * 2.4
        radius:  width / 2
        anchors.centerIn: _dot
        color:   "transparent"
        border.color: root.dotColor
        border.width: 1.5
        opacity: 0

        SequentialAnimation on opacity {
            running:  root.pulsing
            loops:    Animation.Infinite
            NumberAnimation { from: 0; to: 0.6;  duration: 500; easing.type: Easing.OutQuad }
            NumberAnimation { from: 0.6; to: 0;  duration: 900; easing.type: Easing.InQuad }
            PauseAnimation  { duration: 400 }
        }
    }

    // Solid dot
    Rectangle {
        id:     _dot
        width:  root.size
        height: root.size
        radius: width / 2
        color:  root.dotColor
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id:      _lbl
        visible: root.showLabel
        text:    root.status.charAt(0).toUpperCase() + root.status.slice(1)
        color:   Theme.textSecondary
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.textSm
        anchors { left: _dot.right; leftMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
    }
}
