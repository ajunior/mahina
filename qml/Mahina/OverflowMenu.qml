import QtQuick
import Mahina

// Shows first N items inline; remaining items collapse into a "+N more" popup.
//
// Usage:
//   OverflowMenu {
//       menuItems: [
//           { label: "Edit",    icon: Icons.pencil,  action: function() { edit()   } },
//           { label: "Share",   icon: Icons.share,   action: function() { share()  } },
//           { label: "Copy",    icon: Icons.copy,    action: function() { copy()   } },
//           { label: "Archive", icon: Icons.archive, action: function() { archive()} },
//           { label: "Delete",  icon: Icons.trash,   action: function() { del()    } },
//       ]
//       maxVisible: 3
//   }
Item {
    id: root

    property var  menuItems:  []
    property int  maxVisible: 3
    property bool showPopup:  false

    signal itemSelected(var menuItem)

    readonly property var visibleItems: root.menuItems.slice(0, root.maxVisible)
    readonly property var hiddenItems:  root.menuItems.length > root.maxVisible
                                        ? root.menuItems.slice(root.maxVisible) : []

    implicitWidth:  _btnRow.implicitWidth
    implicitHeight: 36

    Row {
        id:     _btnRow
        height: parent.height
        spacing: 4

        Repeater {
            model: root.visibleItems
            delegate: Rectangle {
                id: _rq1
                required property var  modelData
                required property int  index

                height:  34; width: _viLabel.implicitWidth + 16
                radius:  Theme.radiusSm
                color:   _viH.hovered ? Theme.panel : "transparent"
                border.color: Theme.border; border.width: 1
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 80 } }
                HoverHandler { id: _viH }

                Row {
                    id: _viLabel; anchors.centerIn: parent; spacing: 5
                    Text {
                        visible: (_rq1.modelData.icon || "") !== ""
                        text: _rq1.modelData.icon || ""; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textBase
                    }
                    Text {
                        visible: (_rq1.modelData.label || "") !== ""
                        text: _rq1.modelData.label || ""; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                    }
                }

                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (_rq1.modelData.action) _rq1.modelData.action()
                        root.itemSelected(_rq1.modelData)
                    }
                }
            }
        }

        // "+" overflow button
        Rectangle {
            visible: root.hiddenItems.length > 0
            height:  34; width: _moreLabel.implicitWidth + 16
            radius:  Theme.radiusSm
            color:   root.showPopup ? Theme.panel : (_moreH.hovered ? Theme.panel : "transparent")
            border.color: Theme.border; border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 80 } }
            HoverHandler { id: _moreH }

            Text {
                id:             _moreLabel
                anchors.centerIn: parent
                text:           "+" + root.hiddenItems.length + " more"
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
            }

            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: root.showPopup = !root.showPopup
            }
        }
    }

    // Popup
    Rectangle {
        visible:  root.showPopup && root.hiddenItems.length > 0
        anchors { top: parent.bottom; right: parent.right; topMargin: 4 }
        width:  180; height: _popupCol.implicitHeight + 8
        radius: Theme.radiusMd
        color:  Theme.surface
        border.color: Theme.border; border.width: 1
        z: 10

        Column {
            id:    _popupCol
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 4 }
            spacing: 0

            Repeater {
                model: root.hiddenItems
                delegate: Rectangle {
                    id: _rq2
                    required property var  modelData
                    required property int  index
                    width: parent.width; height: 34; radius: Theme.radiusSm
                    color: _piH.hovered ? Theme.panel : "transparent"
                    HoverHandler { id: _piH }
                    Row {
                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                        spacing: 8
                        Text {
                            visible: (_rq2.modelData.icon || "") !== ""
                            text: _rq2.modelData.icon || ""; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textBase
                        }
                        Text { text: _rq2.modelData.label || ""; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.showPopup = false
                            if (_rq2.modelData.action) _rq2.modelData.action()
                            root.itemSelected(_rq2.modelData)
                        }
                    }
                }
            }
        }

        MouseArea { anchors.fill: parent; onClicked: {} }
    }

    MouseArea {
        visible: root.showPopup
        parent:  root.parent
        anchors.fill: parent; z: -1
        onClicked: root.showPopup = false
    }
}
