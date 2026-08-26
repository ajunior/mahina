pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Keyboard-driven command launcher (⌘K palette).
//
// Usage:
//   CommandPalette {
//       id: palette
//       model: [
//           { label: "New file",      icon: Icons.file,        shortcut: "⌘N", group: "File"     },
//           { label: "Toggle theme",  icon: Icons.moonStars,                   group: "Settings" },
//           { label: "Open terminal", icon: Icons.terminal,    shortcut: "⌘`", group: "Tools"    },
//       ]
//       onTriggered: (item) => executeCommand(item)
//   }
//
//   // Open with keyboard shortcut:
//   Shortcut { sequence: "Ctrl+K"; onActivated: palette.open() }
//
// Item shape: { label, icon?, shortcut?, group?, description? }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var    model:       []
    property string placeholder: "Search commands…"
    property int    maxResults:  8

    signal triggered(var item)

    function open(): void {
        root.visible   = true
        _search.text   = ""
        _selectedIdx   = 0
        _search.forceActiveFocus()
    }
    function close(): void { root.visible = false }

    // ── Internal ─────────────────────────────────────────────────────────────
    property int _selectedIdx: 0

    readonly property var _filtered: {
        var q = _search.text.trim().toLowerCase()
        var items = q === "" ? root.model
                             : root.model.filter(function(i) {
                                   return (i.label  ?? "").toLowerCase().includes(q)
                                       || (i.group  ?? "").toLowerCase().includes(q)
                               })
        return items.slice(0, root.maxResults)
    }

    onVisibleChanged: if (!visible) _selectedIdx = 0

    // ── Root overlay ──────────────────────────────────────────────────────────
    anchors.fill: parent
    visible:      false
    z:            9500
    focus:        visible

    // The search field forwards its arrow/return keys here, so the behaviour
    // lives in plain functions rather than being reached by invoking root's
    // attached Keys handlers as if they were methods.
    function _moveUp(): void   { root._selectedIdx = Math.max(0, root._selectedIdx - 1) }
    function _moveDown(): void { root._selectedIdx = Math.min(root._filtered.length - 1, root._selectedIdx + 1) }
    function _activate(): void {
        if (root._filtered[root._selectedIdx]) {
            root.triggered(root._filtered[root._selectedIdx])
            root.close()
        }
    }

    Keys.onEscapePressed: root.close()
    Keys.onUpPressed:     root._moveUp()
    Keys.onDownPressed:   root._moveDown()
    Keys.onReturnPressed: root._activate()

    // Backdrop
    Rectangle {
        anchors.fill: parent
        color:        Theme.overlay
        opacity:      root.visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }
        MouseArea { anchors.fill: parent; onClicked: root.close() }
    }

    // ── Panel ─────────────────────────────────────────────────────────────────
    Rectangle {
        id:               _panel
        anchors.horizontalCenter: parent.horizontalCenter
        y:                Math.max(Theme.sp8, parent.height * 0.12)
        width:            Math.min(560, parent.width - Theme.sp8 * 2)
        height:           _panelCol.implicitHeight
        color:            Theme.surface
        radius:           Theme.radiusLg
        border.color:     Theme.border
        border.width:     1
        opacity:          root.visible ? 1 : 0
        scale:            root.visible ? 1 : 0.96

        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
        Behavior on scale   { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }

        MouseArea { anchors.fill: parent; onClicked: {} }   // eat backdrop clicks

        ColumnLayout {
            id:    _panelCol
            width: parent.width
            spacing: 0

            // ── Search input ──────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth:   true
                Layout.margins:     Theme.sp3
                spacing:            Theme.sp2

                Icon { name: Icons.magnifyingGlass; size: 18; color: Theme.textSecondary }

                TextInput {
                    id:               _search
                    Layout.fillWidth: true
                    color:            Theme.textPrimary
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.textBase
                    clip:             true

                    Text {
                        visible:   _search.text === ""
                        text:      root.placeholder
                        color:     Theme.textDisabled
                        font:      _search.font
                    }

                    Keys.onUpPressed:     (event) => { root._moveUp();   event.accepted = true }
                    Keys.onDownPressed:   (event) => { root._moveDown(); event.accepted = true }
                    Keys.onReturnPressed: (event) => { root._activate(); event.accepted = true }
                    Keys.onEscapePressed: root.close()

                    onTextChanged: root._selectedIdx = 0
                }

                // Clear button
                Rectangle {
                    visible: _search.text !== ""
                    width:   20; height: 20; radius: 10
                    color:   _qHov.hovered ? Theme.border : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _qHov }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: _search.text = "" }
                    Icon { anchors.centerIn: parent; name: Icons.x; size: 11; color: Theme.textSecondary }
                }
            }

            // Divider
            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

            // ── Results ───────────────────────────────────────────────────────
            Column {
                id:               _results
                Layout.fillWidth: true
                padding:          Theme.sp1

                Repeater {
                    model: root._filtered

                    delegate: Rectangle {
                        id:       _item
                        required property var modelData
                        required property int index

                        width:   _results.width - _results.padding * 2
                        height:  40
                        radius:  Theme.radiusSm
                        color:   root._selectedIdx === index
                                 ? Theme.panel
                                 : _iHov.hovered ? Theme.surfaceVariant
                                 : "transparent"

                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                        HoverHandler {
                            id:             _iHov
                            onHoveredChanged: if (hovered) root._selectedIdx = _item.index
                        }

                        RowLayout {
                            anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                            spacing: Theme.sp2

                            // Active indicator
                            Rectangle {
                                width: 2; height: 16; radius: 1
                                color: root._selectedIdx === _item.index ? Theme.primary : "transparent"
                                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                            }

                            Icon {
                                visible: _item.modelData.icon !== undefined && _item.modelData.icon !== ""
                                name:    _item.modelData.icon ?? ""
                                size:    16
                                color:   Theme.textSecondary
                            }

                            Text {
                                text:             _item.modelData.label ?? ""
                                color:            Theme.textPrimary
                                font.family:      Theme.fontFamily
                                font.pixelSize:   Theme.textSm
                                Layout.fillWidth: true
                                elide:            Text.ElideRight
                            }

                            Text {
                                visible:        _item.modelData.group !== undefined && _item.modelData.group !== ""
                                text:           _item.modelData.group ?? ""
                                color:          Theme.textDisabled
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textXs
                            }

                            Kbd {
                                visible: _item.modelData.shortcut !== undefined && _item.modelData.shortcut !== ""
                                keys:    _item.modelData.shortcut ? [_item.modelData.shortcut] : []
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    { root.triggered(_item.modelData); root.close() }
                        }
                    }
                }

                // Empty state
                Item {
                    visible: root._filtered.length === 0
                    width:   parent.width - parent.padding * 2
                    height:  80

                    Text {
                        anchors.centerIn: parent
                        text:    "No results for “" + _search.text + "”"
                        color:   Theme.textDisabled
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.textSm
                    }
                }
            }

            // Footer hint
            Rectangle {
                Layout.fillWidth: true
                height:           32
                color:            Theme.panel
                radius:           Theme.radiusLg

                // Square off top corners
                Rectangle {
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: parent.radius; color: parent.color
                }

                RowLayout {
                    anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                    spacing: Theme.sp3

                    Row { spacing: Theme.sp1
                        Kbd { keys: ["↑"] }
                        Kbd { keys: ["↓"] }
                        Text { text: " navigate"; color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs; leftPadding: Theme.sp1 }
                    }
                    Row { spacing: Theme.sp1
                        Kbd { keys: ["↵"] }
                        Text { text: " select"; color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs; leftPadding: Theme.sp1 }
                    }
                    Row { spacing: Theme.sp1
                        Kbd { keys: ["Esc"] }
                        Text { text: " close"; color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs; leftPadding: Theme.sp1 }
                    }
                    Item { Layout.fillWidth: true }
                }
            }
        }
    }
}
