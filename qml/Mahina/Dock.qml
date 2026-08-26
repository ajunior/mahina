pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// macOS-style icon dock with proximity magnification.
//
// Usage:
//   Dock {
//       apps: [
//           { label: "Finder",   icon: Icons.folder,   color: "#4299e1" },
//           { label: "Mail",     icon: Icons.envelope, color: "#e53e3e" },
//           { label: "Terminal", icon: Icons.terminal, color: "#1a202c" },
//           { label: "Settings", icon: Icons.gear,     color: "#718096" },
//       ]
//       onAppActivated: (app) => openApp(app.label)
//   }
Item {
    id: root

    property var  apps:       []
    property real baseSize:   52
    property real maxSize:    80
    property real magnifyRadius: 100
    property bool showLabels: true

    signal appActivated(var app)

    implicitWidth:  _row.implicitWidth  + Theme.sp5 * 2
    implicitHeight: maxSize + (showLabels ? 24 : 0) + Theme.sp3 * 2 + 8

    property real mouseX: -999
    property real mouseY: -999

    // Track mouse position over the dock
    HoverHandler {
        target: parent
        onPointChanged: {
            root.mouseX = point.position.x
            root.mouseY = point.position.y
        }
        onHoveredChanged: {
            if (!hovered) { root.mouseX = -999; root.mouseY = -999 }
        }
    }

    Rectangle {
        anchors {
            left:   _row.left;   leftMargin:  -Theme.sp5
            right:  _row.right;  rightMargin: -Theme.sp5
            bottom: parent.bottom
        }
        height: root.baseSize + (root.showLabels ? 24 : 0) + Theme.sp3 * 2
        radius: Theme.radiusXl
        color:  Qt.rgba(Qt.color(Theme.surface).r, Qt.color(Theme.surface).g, Qt.color(Theme.surface).b, 0.85)
        border.color: Theme.border; border.width: 1
    }

    Row {
        id:      _row
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:           parent.bottom
        anchors.bottomMargin:     Theme.sp3
        spacing: Theme.sp2

        Repeater {
            model: root.apps
            delegate: Item {
                id: _rq1
                required property var  modelData
                required property int  index

                property real iconCenterX: x + width / 2 + _row.x + root.x
                property real distToMouse: Math.abs(iconCenterX - root.mouseX - root.x)
                property real scaleFactor: {
                    if (root.mouseX < 0) return 1.0
                    var d = distToMouse
                    if (d > root.magnifyRadius) return 1.0
                    return 1.0 + (root.maxSize / root.baseSize - 1.0) * (1.0 - d / root.magnifyRadius)
                }
                property real iconSize: root.baseSize * scaleFactor

                Behavior on iconSize { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

                width:  iconSize
                height: root.maxSize + (root.showLabels ? 24 : 0)

                // Icon background
                Rectangle {
                    id:     _iconBg
                    width:  _rq1.iconSize; height: _rq1.iconSize
                    radius: _rq1.iconSize * 0.22
                    color:  _rq1.modelData.color || Theme.primary
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom:           root.showLabels ? _label.top : parent.bottom
                    anchors.bottomMargin:     root.showLabels ? 4 : 0

                    Behavior on width  { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                    Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

                    // Press animation
                    scale: _iconMA.containsPress ? 0.9 : 1.0
                    Behavior on scale { NumberAnimation { duration: 80 } }

                    Text {
                        anchors.centerIn: parent
                        text:           _rq1.modelData.icon || ""
                        color:          "white"
                        font.family:    Theme.fontFamily
                        font.pixelSize: _rq1.iconSize * 0.52
                        Behavior on font.pixelSize { NumberAnimation { duration: 120 } }
                    }
                }

                // Label
                Text {
                    id:      _label
                    visible: root.showLabels
                    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
                    text:           _rq1.modelData.label || ""
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    id:          _iconMA
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    hoverEnabled: true

                    onDoubleClicked: root.appActivated(_rq1.modelData)
                    onClicked: {
                        _bounce.restart()
                        root.appActivated(_rq1.modelData)
                    }
                }

                // Bounce animation on click
                SequentialAnimation {
                    id: _bounce
                    NumberAnimation { target: _iconBg; property: "anchors.bottomMargin"; to: root.showLabels ? 20 : 16; duration: 100; easing.type: Easing.OutQuad }
                    NumberAnimation { target: _iconBg; property: "anchors.bottomMargin"; to: root.showLabels ? 4 : 0;  duration: 200; easing.type: Easing.InBounce }
                }
            }
        }
    }
}
