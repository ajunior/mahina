pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Controls as QQC
import Mahina

// Command palette / spotlight search overlay.
// Press the trigger key (default Ctrl+K) to open; type to filter commands.
//
// Usage:
//   CommandBar {
//       commands: [
//           { label: "Go to Dashboard",   icon: Icons.home,    action: () => stack.push(dashPage)   },
//           { label: "Toggle dark mode",  icon: Icons.sun,     action: () => Theme.dark = !Theme.dark },
//           { label: "New file",          icon: Icons.filePlus, shortcut: "Ctrl+N", action: () => {} },
//       ]
//   }
Item {
    id: root

    property var    commands:  []
    property bool   open:      false
    property string query:     ""
    property int    maxHeight: 360

    function show(): void { root.open = true; root.query = ""; _search.forceActiveFocus() }
    function hide(): void { root.open = false; root.query = "" }
    function toggle(): void { if (root.open) hide(); else show() }

    readonly property var _filtered: {
        var q   = root.query.toLowerCase()
        var all = root.commands
        if (q === "") return all.slice(0, 8)
        var out = []
        for (var i = 0; i < all.length; i++) {
            if ((all[i].label ?? "").toLowerCase().indexOf(q) >= 0) out.push(all[i])
        }
        return out.slice(0, 8)
    }

    property int _selected: 0

    // Global shortcut
    Shortcut { sequence: "Ctrl+K"; onActivated: root.toggle() }

    QQC.Popup {
        id:     _popup
        anchors.centerIn: Overlay.overlay
        width:  480
        height: Math.min(root.maxHeight, 52 + root._filtered.length * 44 + 16)
        visible: root.open
        modal:   true
        padding: 0
        closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside

        onClosed: root.open = false

        background: Rectangle {
            radius:       Theme.radiusLg
            color:        Theme.surface
            border.color: Theme.border
            border.width: 1
        }

        Column {
            anchors.fill: parent
            spacing: 0

            // Search row
            Rectangle {
                width:  parent.width; height: 52
                color:  "transparent"
                radius: Theme.radiusLg

                Row {
                    anchors { fill: parent; leftMargin: Theme.sp4; rightMargin: Theme.sp4 }
                    spacing: Theme.sp2

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text:           "⌕"
                        color:          Theme.textDisabled
                        font.pixelSize: Theme.textLg
                    }

                    Item {
                        width: parent.width - 40
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            visible:        _search.text === ""
                            anchors.verticalCenter: parent.verticalCenter
                            text:           "Search commands…"
                            color:          Theme.textDisabled
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textBase
                        }

                    TextInput {
                        id:             _search
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                        text:           root.query
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textBase
                        selectByMouse:  true

                        onTextChanged: {
                            root.query = text
                            root._selected = 0
                        }

                        Keys.onPressed: (e) => {
                            if (e.key === Qt.Key_Up) {
                                root._selected = Math.max(0, root._selected - 1); e.accepted = true
                            } else if (e.key === Qt.Key_Down) {
                                root._selected = Math.min(root._filtered.length - 1, root._selected + 1); e.accepted = true
                            } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                if (root._selected < root._filtered.length) {
                                    var cmd = root._filtered[root._selected]
                                    if (cmd && cmd.action) cmd.action()
                                    root.hide()
                                }
                                e.accepted = true
                            } else if (e.key === Qt.Key_Escape) {
                                root.hide(); e.accepted = true
                            }
                        }
                    }
                    } // Item wrapper
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border }

            // Results
            Column {
                width: parent.width
                spacing: 0
                padding: Theme.sp2

                Repeater {
                    model: root._filtered
                    delegate: Rectangle {
                        id: _rq1
                        required property var modelData
                        required property int index
                        width:  parent.width - Theme.sp2 * 2
                        height: 40
                        radius: Theme.radiusMd
                        color:  index === root._selected ? Theme.surfaceVariant : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered:  root._selected = _rq1.index
                            onClicked: {
                                if (_rq1.modelData && _rq1.modelData.action) _rq1.modelData.action()
                                root.hide()
                            }
                        }

                        Row {
                            anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                            spacing: Theme.sp2

                            Text {
                                visible:        (_rq1.modelData.icon ?? "") !== ""
                                anchors.verticalCenter: parent.verticalCenter
                                text:           _rq1.modelData.icon ?? ""
                                color:          Theme.textSecondary
                                font.pixelSize: Theme.textBase
                                font.family:    Theme.fontFamily
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text:           _rq1.modelData.label ?? ""
                                color:          Theme.textPrimary
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textSm
                                elide:          Text.ElideRight
                                width:          parent.width - 100
                            }

                            Text {
                                visible:        (_rq1.modelData.shortcut ?? "") !== ""
                                anchors.verticalCenter: parent.verticalCenter
                                text:           _rq1.modelData.shortcut ?? ""
                                color:          Theme.textDisabled
                                font.family:    Theme.fontFamilyMono
                                font.pixelSize: Theme.textXs
                            }
                        }
                    }
                }
            }
        }
    }
}
