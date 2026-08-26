pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Mahina

// Frosted-glass backdrop. Place it behind a panel to blur the content beneath.
//
// Usage:
//   Item {
//       SomeBackground { id: bg }
//       BlurOverlay { source: bg; anchors.fill: bg; radius: 20 }
//       ForegroundPanel { }
//   }
Item {
    id: root

    property real   radius:     20
    property color  tintColor:  Qt.rgba(Qt.color(Theme.surface).r, Qt.color(Theme.surface).g, Qt.color(Theme.surface).b, 0.6)
    property var    source:     null

    MultiEffect {
        anchors.fill: parent
        source:       root.source
        blurEnabled:  true
        blur:         Math.min(1, root.radius / 64)
        blurMax:      64
        blurMultiplier: 1.0
    }

    Rectangle {
        anchors.fill: parent
        color:        root.tintColor
    }
}
