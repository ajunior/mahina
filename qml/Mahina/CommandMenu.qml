pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Mahina

// Spotlight-style command palette with search + keyboard navigation.
//
// Usage:
//   CommandMenu {
//       id: _cmd
//       sections: [
//           { heading: "Navigation",
//             items: [
//               { icon: Icons.house, label: "Go Home",    shortcut: "G H", action: function(){ nav.home() }   },
//               { icon: Icons.gear,  label: "Settings",   shortcut: "G S", action: function(){ nav.settings() }},
//             ]
//           }
//       ]
//   }
//   // Open with: _cmd.open = true
Item {
    id: root

    property bool   isOpen:   false
    property var    sections: []
    property string placeholder: "Search commands…"

    signal commandRan(string label)

    anchors.fill: parent
    visible: root.isOpen
    z: 9000

    // Compute filtered flat list
    readonly property var filteredItems: {
        var q = _searchInput.text.trim().toLowerCase()
        var result = []
        for (var si = 0; si < root.sections.length; si++) {
            var sec = root.sections[si]
            var hits = []
            var items = sec.items || []
            for (var ii = 0; ii < items.length; ii++) {
                if (q === "" || (items[ii].label || "").toLowerCase().indexOf(q) !== -1)
                    hits.push(items[ii])
            }
            if (hits.length > 0) result.push({ heading: sec.heading, items: hits })
        }
        return result
    }

    property int activeIdx: 0

    // Flat list for keyboard nav
    readonly property var flatItems: {
        var out = []
        for (var s = 0; s < root.filteredItems.length; s++)
            for (var i = 0; i < root.filteredItems[s].items.length; i++)
                out.push(root.filteredItems[s].items[i])
        return out
    }

    function _runActive(): void {
        if (root.activeIdx < root.flatItems.length) {
            var it = root.flatItems[root.activeIdx]
            root.isOpen = false
            root.commandRan(it.label || "")
            if (it.action) it.action()
        }
    }

    // Overlay
    Rectangle {
        anchors.fill: parent
        color:        Qt.rgba(0, 0, 0, 0.45)
        MouseArea {
            anchors.fill: parent
            onClicked:    root.isOpen = false
        }
    }

    // Palette panel
    Rectangle {
        id:     _panel
        width:  Math.min(560, parent.width - 48)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top; anchors.topMargin: 80
        implicitHeight: _content.implicitHeight + 2
        height: Math.min(implicitHeight, root.height - 160)
        radius: Theme.radiusLg
        color:  Theme.surface
        border.color: Theme.border; border.width: 1
        clip: true

        opacity: root.isOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

        Column {
            id:    _content
            width: parent.width

            // Search box
            Rectangle {
                width:  parent.width
                height: 48
                color:  "transparent"

                Row {
                    anchors { fill: parent; leftMargin: 14 }
                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text:           "⌕"
                        color:          Theme.textSecondary
                        font.pixelSize: Theme.textLg
                    }

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 40
                        height: _searchInput.height

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:    root.placeholder
                            visible: _searchInput.text === ""
                            color:   Theme.textDisabled
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textBase
                        }

                        TextInput {
                            id:             _searchInput
                            anchors.verticalCenter: parent.verticalCenter
                            width:          parent.width
                            color:          Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textBase

                            onTextChanged: root.activeIdx = 0

                            Keys.onEscapePressed:    root.isOpen = false
                            Keys.onReturnPressed:    root._runActive()
                            Keys.onUpPressed:   (e) => { root.activeIdx = Math.max(0, root.activeIdx - 1); e.accepted = true }
                            Keys.onDownPressed: (e) => { root.activeIdx = Math.min(root.flatItems.length - 1, root.activeIdx + 1); e.accepted = true }
                        }
                    }
                }

                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border }
            }

            // Results
            Flickable {
                width:         parent.width
                contentHeight: _resultCol.implicitHeight
                height:        Math.min(contentHeight, _panel.height - 48)
                clip: true

                Column {
                    id:    _resultCol
                    width: parent.width

                    Repeater {
                        model: root.filteredItems
                        delegate: Column {
                            id: _rq1
                            required property var modelData
                            width: parent.width

                            // Section heading
                            Rectangle {
                                width: parent.width; height: 26
                                color: Theme.surfaceVariant

                                Text {
                                    anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                                    text:           _rq1.modelData.heading || ""
                                    color:          Theme.textDisabled
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: Theme.textXs
                                    font.weight:    Font.Medium
                                }
                            }

                            // Commands in section
                            Repeater {
                                model: _rq1.modelData.items
                                delegate: Rectangle {
                                    id: _rq2
                                    required property var  modelData
                                    required property int  index

                                    // Compute global flat index for active tracking
                                    readonly property int globalIdx: {
                                        var base = 0
                                        var sIdx = _outerRep.itemAt(parent.parent.parent.ObjectModel.index) ? parent.parent.parent.ObjectModel.index : 0
                                        // Simpler: find by label
                                        for (var fi = 0; fi < root.flatItems.length; fi++)
                                            if (root.flatItems[fi] === modelData) return fi
                                        return -1
                                    }

                                    width:  parent.width
                                    height: 42
                                    color:  globalIdx === root.activeIdx ? Theme.panel : "transparent"
                                    Behavior on color { ColorAnimation { duration: 80 } }

                                    HoverHandler {
                                        onHoveredChanged: if (hovered) root.activeIdx = globalIdx
                                    }

                                    Row {
                                        anchors { left: parent.left; right: parent.right;
                                                  leftMargin: 14; rightMargin: 14; verticalCenter: parent.verticalCenter }
                                        spacing: 10

                                        Text {
                                            text:           _rq2.modelData.icon || ""
                                            color:          Theme.textSecondary
                                            font.family:    Theme.fontFamily
                                            font.pixelSize: Theme.textBase
                                        }
                                        Text {
                                            text:           _rq2.modelData.label || ""
                                            color:          Theme.textPrimary
                                            font.family:    Theme.fontFamily
                                            font.pixelSize: Theme.textBase
                                            width:          parent.width - 60
                                            elide:          Text.ElideRight
                                        }
                                        Item { width: 1; height: 1 }
                                        Text {
                                            visible:        (_rq2.modelData.shortcut || "") !== ""
                                            text:           _rq2.modelData.shortcut || ""
                                            color:          Theme.textDisabled
                                            font.family:    Theme.fontFamilyMono
                                            font.pixelSize: Theme.textXs
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.isOpen = false
                                            root.commandRan(_rq2.modelData.label || "")
                                            if (_rq2.modelData.action) _rq2.modelData.action()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Empty state
                    Rectangle {
                        visible: root.flatItems.length === 0
                        width: parent.width; height: 80; color: "transparent"
                        Text {
                            anchors.centerIn: parent
                            text:           "No commands found"
                            color:          Theme.textDisabled
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                        }
                    }
                }
            }
        }
    }

    Repeater { id: _outerRep; model: root.filteredItems }

    onIsOpenChanged: {
        if (root.isOpen) {
            _searchInput.text = ""
            root.activeIdx = 0
            _searchInput.forceActiveFocus()
        }
    }
}
