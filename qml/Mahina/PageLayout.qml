pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Standard app page layout: header + optional sidebar + scrollable content area.
//
// Usage:
//   PageLayout {
//       title: "Dashboard"
//       actions: Row { Button { text: "Export" } }
//       sidebar: SidebarContent { }
//       content: DashboardGrid { ... }
//   }
Item {
    id: root

    property string title:        ""
    property alias  actions:      _actionsSlot.children
    property alias  sidebar:      _sidebarSlot.children
    property alias  content:      _contentSlot.children
    property real   sidebarWidth: 220
    property bool   hasSidebar:   _sidebarSlot.children.length > 0
    property int    headerHeight: 56

    implicitWidth:  800
    implicitHeight: 600

    // Header
    Rectangle {
        id:     _header
        width:  parent.width; height: root.headerHeight
        color:  Theme.surface
        border.color: Theme.border; border.width: 1

        Text {
            anchors { left: parent.left; leftMargin: Theme.sp4; verticalCenter: parent.verticalCenter }
            text:           root.title
            color:          Theme.textPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textLg
            font.weight:    Theme.weightSemibold
        }

        Item {
            id:     _actionsSlot
            anchors { right: parent.right; rightMargin: Theme.sp4; verticalCenter: parent.verticalCenter }
            width:  childrenRect.width; height: childrenRect.height
        }
    }

    // Body
    Row {
        anchors { top: _header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        spacing: 0

        // Sidebar
        Rectangle {
            visible: root.hasSidebar
            width:   root.hasSidebar ? root.sidebarWidth : 0
            height:  parent.height
            color:   Theme.panel
            border.color: Theme.border; border.width: 1

            Item {
                id:     _sidebarSlot
                anchors { fill: parent; margins: Theme.sp3 }
            }
        }

        // Content
        Rectangle {
            width:  root.hasSidebar ? parent.width - root.sidebarWidth : parent.width
            height: parent.height
            color:  Theme.background

            Flickable {
                anchors.fill: parent
                contentWidth:  width
                contentHeight: _contentSlot.implicitHeight + Theme.sp4 * 2

                Item {
                    id:     _contentSlot
                    x:      Theme.sp4; y: Theme.sp4
                    width:  parent.width - Theme.sp4 * 2
                    implicitHeight: childrenRect.height
                }
            }
        }
    }
}
