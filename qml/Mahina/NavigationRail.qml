import QtQuick
import Mahina

// Narrow vertical navigation bar — collapses to icon-only.
//
// Usage:
//   NavigationRail {
//       navItems: [
//           { icon: Icons.house,    label: "Home",     badge: 0  },
//           { icon: Icons.envelope, label: "Messages", badge: 12 },
//           { icon: Icons.gear,     label: "Settings", badge: 0  },
//       ]
//       activeIndex: 0
//       onItemSelected: (i) => currentPage = i
//   }
Rectangle {
    id: root

    property var  navItems:    []
    property int  activeIndex: 0
    property bool collapsed:   false

    signal itemSelected(int idx)

    implicitWidth:  root.collapsed ? 56 : 180
    implicitHeight: 400

    Behavior on implicitWidth { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutQuad } }
    Behavior on width         { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutQuad } }

    color:  Theme.surface
    border.color: Theme.border; border.width: 1
    radius: Theme.radiusMd

    Column {
        anchors { fill: parent; margins: 6 }
        spacing: 2

        // Collapse toggle
        Rectangle {
            width:  parent.width
            height: 40
            radius: Theme.radiusSm
            color:  _colH.hovered ? Theme.panel : "transparent"
            Behavior on color { ColorAnimation { duration: 100 } }
            HoverHandler { id: _colH }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 13
                anchors.verticalCenter: parent.verticalCenter
                text:           root.collapsed ? "→" : "←"
                color:          Theme.textSecondary
                font.pixelSize: Theme.textBase
                font.family:    Theme.fontFamily
            }

            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: root.collapsed = !root.collapsed
            }
        }

        // Separator
        Rectangle { width: parent.width; height: 1; color: Theme.border }

        Repeater {
            model: root.navItems
            delegate: Rectangle {
                id: _rq1
                required property var  modelData
                required property int  index

                width:  parent.width
                height: 44
                radius: Theme.radiusSm

                readonly property bool isActive: index === root.activeIndex

                color: isActive ? Qt.rgba(Qt.color(Theme.primary).r,
                                          Qt.color(Theme.primary).g,
                                          Qt.color(Theme.primary).b, 0.1)
                                : (_itemH.hovered ? Theme.panel : "transparent")
                Behavior on color { ColorAnimation { duration: 100 } }

                HoverHandler { id: _itemH }

                // Left accent bar when active
                Rectangle {
                    visible: isActive
                    width:   3; height: 22; radius: 2
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    color: Theme.primary
                }

                Row {
                    anchors {
                        left: parent.left; leftMargin: 14
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 10

                    Text {
                        text:           _rq1.modelData.icon || ""
                        color:          isActive ? Theme.primary : Theme.textSecondary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textBase
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    Text {
                        visible:        !root.collapsed
                        text:           _rq1.modelData.label || ""
                        color:          isActive ? Theme.primary : Theme.textSecondary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textSm
                        font.weight:    isActive ? Font.Medium : Font.Normal
                        opacity:        root.collapsed ? 0 : 1
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        Behavior on color   { ColorAnimation  { duration: 100 } }
                    }
                }

                // Badge
                Rectangle {
                    visible:  (_rq1.modelData.badge || 0) > 0
                    anchors { right: parent.right; top: parent.top; rightMargin: 8; topMargin: 8 }
                    width:   _badgeNum.implicitWidth + 6
                    height:  16; radius: 8
                    color:   Theme.error

                    Text {
                        id:             _badgeNum
                        anchors.centerIn: parent
                        text:           (_rq1.modelData.badge || 0) > 99 ? "99+" : (_rq1.modelData.badge || 0).toString()
                        color:          Theme.textOnPrimary
                        font.pixelSize: 9
                        font.family:    Theme.fontFamily
                        font.weight:    Font.Bold
                    }
                }

                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.activeIndex = _rq1.index
                        root.itemSelected(_rq1.index)
                    }
                }
            }
        }
    }
}
