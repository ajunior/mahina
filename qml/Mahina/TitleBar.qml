pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Custom frameless window title bar with traffic-light controls.
//
// Usage:
//   TitleBar {
//       windowTitle:  "My Application"
//       maximized:    false
//       onCloseClicked:    Qt.quit()
//       onMinimizeClicked: window.showMinimized()
//       onMaximizeClicked: window.showMaximized()
//   }
Item {
    id: root

    property string windowTitle:   ""
    property bool   maximized:     false
    property bool   showMinimize:  true
    property bool   showMaximize:  true
    property bool   showClose:     true

    signal closeClicked()
    signal minimizeClicked()
    signal maximizeClicked()
    signal dragStarted(real x, real y)
    signal dragged(real dx, real dy)

    implicitWidth:  400
    implicitHeight: 38

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceVariant

        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1; color: Theme.border
        }

        // Title text (centered)
        Text {
            anchors.centerIn: parent
            text:           root.windowTitle
            color:          Theme.textPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            font.weight:    Font.Medium
            elide:          Text.ElideMiddle
            width:          Math.min(implicitWidth, parent.width - 160)
        }

        // Drag area (double-click to maximize)
        MouseArea {
            id:          _drag
            anchors { fill: parent; rightMargin: 120 }
            // Global coordinates: the title bar moves with the window it drags,
            // so a delta measured against the drag area itself is always zero.
            property real pressX: 0; property real pressY: 0
            onPressed:  (m) => {
                var g = _drag.mapToGlobal(m.x, m.y)
                pressX = g.x; pressY = g.y
                root.dragStarted(g.x, g.y)
            }
            onPositionChanged: (m) => {
                if (!_drag.pressed) return
                var g = _drag.mapToGlobal(m.x, m.y)
                root.dragged(g.x - pressX, g.y - pressY)
            }
            onDoubleClicked: root.maximizeClicked()
        }

        // Window controls (right side)
        Row {
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
            spacing: 0

            // Minimize
            Rectangle {
                visible: root.showMinimize
                width: 46; height: parent.height
                color: _minH.hovered ? Theme.hover : "transparent"
                Behavior on color { ColorAnimation { duration: 80 } }
                HoverHandler { id: _minH }
                Text { anchors.centerIn: parent; text: "─"; color: Theme.textSecondary; font.pixelSize: 13 }
                MouseArea { anchors.fill: parent; onClicked: root.minimizeClicked() }
            }

            // Maximize / restore
            Rectangle {
                visible: root.showMaximize
                width: 46; height: parent.height
                color: _maxH.hovered ? Theme.hover : "transparent"
                Behavior on color { ColorAnimation { duration: 80 } }
                HoverHandler { id: _maxH }
                Text {
                    anchors.centerIn: parent
                    text:  root.maximized ? "❐" : "□"
                    color: Theme.textSecondary; font.pixelSize: 13
                }
                MouseArea { anchors.fill: parent; onClicked: root.maximizeClicked() }
            }

            // Close
            Rectangle {
                visible: root.showClose
                width: 46; height: parent.height
                color: _clsH.hovered ? "#e81123" : "transparent"
                Behavior on color { ColorAnimation { duration: 80 } }
                HoverHandler { id: _clsH }
                Text {
                    anchors.centerIn: parent
                    text:  "✕"
                    color: _clsH.hovered ? "white" : Theme.textSecondary
                    font.pixelSize: 11
                }
                MouseArea { anchors.fill: parent; onClicked: root.closeClicked() }
            }
        }
    }
}
