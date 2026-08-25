import QtQuick
import Mahina

// Application-level menu bar with keyboard-navigable dropdown menus.
//
// Usage:
//   MenuBar {
//       menus: [
//           { label: "File", items: [
//               { label: "New",  shortcut: "Ctrl+N", action: function() { newFile() } },
//               { separator: true },
//               { label: "Quit", shortcut: "Ctrl+Q", action: function() { Qt.quit() } },
//           ]},
//           { label: "Edit", items: [ ... ] },
//       ]
//   }
Item {
    id: root

    property var menus:      []
    property int activeMenu: -1

    signal menuItemTriggered(string label)

    implicitWidth:  _mbRow.implicitWidth
    implicitHeight: 30

    Row {
        id:     _mbRow
        height: parent.height

        Repeater {
            model: root.menus
            delegate: Item {
                id: _rq1
                required property var modelData
                required property int index

                width:  _mbLbl.implicitWidth + 20
                height: parent.height

                readonly property bool isActive: root.activeMenu === index

                Rectangle {
                    anchors.fill: parent
                    color:  isActive ? Theme.primary : (_mbH.hovered ? Theme.panel : "transparent")
                    radius: Theme.radiusSm
                    Behavior on color { ColorAnimation { duration: 80 } }
                }

                Text {
                    id:             _mbLbl
                    anchors.centerIn: parent
                    text:           _rq1.modelData.label || ""
                    color:          isActive ? Theme.textOnPrimary : Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                }

                HoverHandler { id: _mbH }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.activeMenu = (root.activeMenu === _rq1.index ? -1 : _rq1.index)
                }

                // Dropdown panel
                Rectangle {
                    visible:  isActive && (_rq1.modelData.items || []).length > 0
                    anchors { top: parent.bottom; left: parent.left; topMargin: 2 }
                    width:  220
                    height: _dropCol.implicitHeight + 8
                    radius: Theme.radiusMd
                    color:  Theme.surface
                    border.color: Theme.border; border.width: 1
                    z: 100

                    Column {
                        id:    _dropCol
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 4 }
                        spacing: 0

                        Repeater {
                            model: _rq1.modelData.items || []
                            delegate: Item {
                                id: _rq2
                                required property var  modelData
                                required property int  index
                                width:  parent.width
                                height: modelData.separator ? 9 : 30

                                // Normal item
                                Rectangle {
                                    visible: !_rq2.modelData.separator
                                    anchors.fill: parent
                                    radius: Theme.radiusSm
                                    color:  _itH.hovered ? Theme.panel : "transparent"
                                    HoverHandler { id: _itH }

                                    Row {
                                        anchors { left: parent.left; right: parent.right
                                                  leftMargin: 10; rightMargin: 10
                                                  verticalCenter: parent.verticalCenter }
                                        spacing: 0

                                        Text {
                                            width: parent.width - _shLbl.implicitWidth
                                            text:           _rq2.modelData.label || ""
                                            color:          Theme.textPrimary
                                            font.family:    Theme.fontFamily
                                            font.pixelSize: Theme.textSm
                                        }

                                        Text {
                                            id:             _shLbl
                                            text:           _rq2.modelData.shortcut || ""
                                            color:          Theme.textDisabled
                                            font.family:    Theme.fontFamily
                                            font.pixelSize: Theme.textXs
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (_rq2.modelData.action) _rq2.modelData.action()
                                            root.menuItemTriggered(_rq2.modelData.label || "")
                                            root.activeMenu = -1
                                        }
                                    }
                                }

                                // Separator
                                Rectangle {
                                    visible:  !!_rq2.modelData.separator
                                    anchors { left: parent.left; right: parent.right
                                              verticalCenter: parent.verticalCenter
                                              leftMargin: 8; rightMargin: 8 }
                                    height: 1; color: Theme.border
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Dismiss on outside click
    MouseArea {
        visible: root.activeMenu >= 0
        parent:  root.parent
        anchors.fill: parent
        z: -1
        onClicked: root.activeMenu = -1
    }
}
