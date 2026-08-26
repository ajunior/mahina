pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Closable, reorderable tab bar with overflow "+N" menu.
//
// Usage:
//   TabDock {
//       tabItems: [
//           { id: "home",  label: "Home",       closable: false },
//           { id: "docs",  label: "Docs",        closable: true  },
//           { id: "api",   label: "API Ref",     closable: true  },
//       ]
//       onTabSelected: (idx) => loadTab(idx)
//       onTabClosed:   (idx) => removetab(idx)
//   }
Item {
    id: root

    property var tabItems:   []
    property int activeTab:  0
    property int maxVisible: 6

    signal tabSelected(int idx)
    signal tabClosed(int idx)

    implicitWidth:  400
    implicitHeight: 38

    property bool showOverflow: false

    readonly property var visibleTabs: root.tabItems.slice(0, root.maxVisible)
    readonly property var hiddenTabs:  root.tabItems.length > root.maxVisible
                                       ? root.tabItems.slice(root.maxVisible) : []

    Row {
        id:     _tabRow
        height: parent.height
        spacing: 0

        Repeater {
            model: root.visibleTabs
            delegate: Item {
                id: _rq1
                required property var  modelData
                required property int  index
                width:  _tabLabel.implicitWidth + 28 + (modelData.closable ? 20 : 0)
                height: parent.height

                readonly property bool isActive: index === root.activeTab

                // Tab body
                Rectangle {
                    anchors.fill: parent
                    color: _rq1.isActive ? Theme.surface : (_tH.hovered ? Theme.hover : "transparent")
                    Behavior on color { ColorAnimation { duration: 100 } }

                    // Bottom or top indicator
                    Rectangle {
                        visible: _rq1.isActive
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                        height:  2; color: Theme.primary
                    }

                    // Right border divider
                    Rectangle {
                        anchors { right: parent.right; top: parent.top; bottom: parent.bottom; topMargin: 6; bottomMargin: 6 }
                        width: 1; color: Theme.border
                        visible: !_rq1.isActive && _rq1.index < root.visibleTabs.length - 1
                    }

                    HoverHandler { id: _tH }

                    Row {
                        anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                        spacing: 6

                        Text {
                            id:             _tabLabel
                            text:           _rq1.modelData.label || ""
                            color:          _rq1.isActive ? Theme.textPrimary : Theme.textSecondary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    _rq1.isActive ? Font.Medium : Font.Normal
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        Rectangle {
                            visible: _rq1.modelData.closable || false
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16; height: 16; radius: 4
                            color: _xH.hovered ? Theme.error : "transparent"
                            Behavior on color { ColorAnimation { duration: 80 } }
                            HoverHandler { id: _xH }
                            Text { anchors.centerIn: parent; text: "✕"; color: _xH.hovered ? Theme.textOnPrimary : Theme.textDisabled; font.pixelSize: 8 }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: (mouse) => { mouse.accepted = true; root.tabClosed(_rq1.index) } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { root.activeTab = _rq1.index; root.tabSelected(_rq1.index) }
                    }
                }
            }
        }

        // "+N more" button
        Rectangle {
            visible: root.hiddenTabs.length > 0
            height: parent.height
            width:  _overflowLbl.implicitWidth + 16
            color:  _ovH.hovered ? Theme.hover : "transparent"
            Behavior on color { ColorAnimation { duration: 100 } }
            HoverHandler { id: _ovH }

            Text {
                id:             _overflowLbl
                anchors.centerIn: parent
                text:           "+" + root.hiddenTabs.length
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
            }

            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: root.showOverflow = !root.showOverflow
            }
        }
    }

    // Bottom border
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1; color: Theme.border
    }

    // Overflow dropdown
    Rectangle {
        visible:  root.showOverflow && root.hiddenTabs.length > 0
        anchors { top: parent.bottom; right: parent.right; topMargin: 2 }
        width:  160; height: _ovMenu.implicitHeight + 8
        radius: Theme.radiusMd
        color:  Theme.surface
        border.color: Theme.border; border.width: 1
        z: 10

        Column {
            id:    _ovMenu
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 4 }
            spacing: 0

            Repeater {
                model: root.hiddenTabs
                delegate: Rectangle {
                    id: _rq2
                    required property var  modelData
                    required property int  index
                    width: parent.width; height: 32; radius: Theme.radiusSm
                    color: _ohH.hovered ? Theme.hover : "transparent"
                    HoverHandler { id: _ohH }
                    Text {
                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                        text: _rq2.modelData.label || ""; color: Theme.textPrimary
                        font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.showOverflow = false
                            root.activeTab = root.maxVisible + _rq2.index
                            root.tabSelected(root.maxVisible + _rq2.index)
                        }
                    }
                }
            }
        }

        MouseArea { anchors.fill: parent; onClicked: {} }
    }

    MouseArea {
        visible: root.showOverflow
        parent: root.parent
        anchors.fill: parent
        z: -1
        onClicked: root.showOverflow = false
    }
}
