pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Drag-to-reorder list. Items swap positions as you drag over them.
//
// Usage:
//   Sortable {
//       width: 300
//       items: ["Design", "Engineering", "Marketing", "Product"]
//       onReordered: (list) => saveOrder(list)
//   }
//
//   // Object items with icon:
//   Sortable {
//       items: [
//           { label: "High priority",   icon: Icons.arrowUp   },
//           { label: "Medium priority", icon: Icons.minus      },
//           { label: "Low priority",    icon: Icons.arrowDown  },
//       ]
//   }
//
// Item shape: string  OR  { label, description?, icon? }
Item {
    id: root

    property var    items:     []
    property real   rowHeight: 48
    property bool   disabled:  false

    signal reordered(var items)

    implicitWidth:  300
    implicitHeight: _lm.count * root.rowHeight

    function _label(item: var): var { return typeof item === "string" ? item : (item.label ?? "") }
    function _desc(item: var): var { return typeof item === "string" ? "" : (item.description ?? "") }
    function _icon(item: var): var { return typeof item === "string" ? "" : (item.icon ?? "") }

    // Internal ListModel keeps a live copy
    ListModel { id: _lm }

    onItemsChanged: {
        _lm.clear()
        for (var i = 0; i < root.items.length; i++) {
            var it = root.items[i]
            _lm.append({
                _label: root._label(it),
                _desc:  root._desc(it),
                _icon:  root._icon(it),
                _src:   it
            })
        }
    }

    Component.onCompleted: {
        _lm.clear()
        for (var i = 0; i < root.items.length; i++) {
            var it = root.items[i]
            _lm.append({ _label: root._label(it), _desc: root._desc(it), _icon: root._icon(it), _src: it })
        }
    }

    function _emitReordered(): void {
        var arr = []
        for (var i = 0; i < _lm.count; i++) arr.push(_lm.get(i)._src)
        root.reordered(arr)
    }

    ListView {
        id:           _list
        anchors.fill: parent
        model:        _lm
        interactive:  false    // no native scroll; height = content

        displaced: Transition {
            NumberAnimation { properties: "y"; duration: 150; easing.type: Easing.OutCubic }
        }

        delegate: Item {
            id: _outer
            required property string _label
            required property string _desc
            required property string _icon
            required property int    index

            width:  _list.width
            height: root.rowHeight
            z:      _content.Drag.active ? 1 : 0

            // ── Visual content (reparented during drag) ───────────────────────
            Rectangle {
                id:     _content
                width:  _outer.width
                height: root.rowHeight
                color:  Drag.active ? Theme.primarySubtle : _rH.hovered ? Theme.panel : Theme.surface
                radius: Theme.radiusSm
                border.color: Drag.active ? Theme.primary : Theme.border
                border.width: 1

                Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                HoverHandler { id: _rH; enabled: !Drag.active }

                Drag.active: _ma.drag.active
                Drag.source: _outer
                Drag.hotSpot.y: height / 2

                states: State {
                    when: _content.Drag.active
                    ParentChange    { target: _content; parent: _list }
                    PropertyChanges { target: _content; width: _list.width; height: root.rowHeight }
                }

                RowLayout {
                    anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                    spacing: Theme.sp3

                    // Drag handle
                    Item {
                        width: 24; height: parent.height
                        MouseArea {
                            id:          _ma
                            anchors.fill:parent
                            drag.target: _content
                            drag.axis:   Drag.YAxis
                            enabled:     !root.disabled
                            cursorShape: Qt.SizeVerCursor
                            onReleased:  _content.Drag.drop()
                        }
                        Icon {
                            anchors.centerIn: parent
                            name:  Icons.dotsSixVertical
                            size:  16
                            color: Theme.textDisabled
                        }
                    }

                    Icon {
                        visible: _outer._icon !== ""
                        name:    _outer._icon !== "" ? _outer._icon : Icons.dotsSixVertical
                        size:    16; color: Theme.textSecondary
                    }

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true

                        Text {
                            text:           _outer._label
                            color:          Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    Theme.weightMedium
                            Layout.fillWidth: true
                        }
                        Text {
                            visible:        _outer._desc !== ""
                            text:           _outer._desc
                            color:          Theme.textDisabled
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textXs
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // ── Drop zone ─────────────────────────────────────────────────────
            DropArea {
                anchors { fill: parent; topMargin: root.rowHeight * 0.2; bottomMargin: root.rowHeight * 0.2 }
                onEntered: (drag) => {
                    var from = drag.source.index
                    var to   = _outer.index
                    if (from !== to) {
                        _lm.move(from, to, 1)
                        root._emitReordered()
                    }
                }
            }
        }
    }
}
