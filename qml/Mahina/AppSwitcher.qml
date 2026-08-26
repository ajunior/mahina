pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Waffle-menu grid of application tiles.
//
// Usage:
//   AppSwitcher {
//       open: _waffle
//       apps: [
//           { label: "Analytics", icon: Icons.chartBar,  color: Theme.primary },
//           { label: "Calendar",  icon: Icons.calendar,  color: Theme.success },
//           { label: "Inbox",     icon: Icons.envelope,  color: Theme.warning },
//           { label: "Settings",  icon: Icons.gear,      color: Theme.error   },
//       ]
//       onAppSelected: (app) => openApp(app.label)
//   }
Item {
    id: root

    property bool open:     false
    property var  apps:     []
    property int  columns:  3
    property real tileSize: 80

    signal appSelected(var app)

    implicitWidth:  columns * (tileSize + Theme.sp2) - Theme.sp2
    implicitHeight: open ? _grid.implicitHeight + Theme.sp3 * 2 : 0

    Behavior on implicitHeight { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
    clip: true

    Rectangle {
        anchors.fill: parent
        color:        Theme.surface
        radius:       Theme.radiusLg
        border.color: Theme.border; border.width: 1

        Item {
            id:     _grid
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp3 }
            implicitHeight: Math.ceil(root.apps.length / root.columns) * (root.tileSize + Theme.sp2) - Theme.sp2

            Repeater {
                model: root.apps
                delegate: Rectangle {
                    id: _rq1
                    required property var  modelData
                    required property int  index

                    x: (index % root.columns) * (root.tileSize + Theme.sp2)
                    y: Math.floor(index / root.columns) * (root.tileSize + Theme.sp2)
                    width: root.tileSize; height: root.tileSize
                    radius: Theme.radiusLg
                    color: _tH.hovered ? Theme.hover : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _tH }

                    Column {
                        anchors.centerIn: parent
                        spacing: Theme.sp2

                        Rectangle {
                            width: 40; height: 40; radius: Theme.radiusMd
                            color: _rq1.modelData.color ?? Theme.primary
                            anchors.horizontalCenter: parent.horizontalCenter

                            Text {
                                anchors.centerIn: parent
                                text:  _rq1.modelData.icon ?? "●"
                                color: "#ffffff"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.textLg
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:           _rq1.modelData.label ?? ""
                            color:          Theme.textSecondary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textXs
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.appSelected(_rq1.modelData); root.open = false }
                    }
                }
            }
        }
    }
}
