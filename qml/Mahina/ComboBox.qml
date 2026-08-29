pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Searchable single-select dropdown. Combines an Input with a Dropdown list.
//
// Usage:
//   ComboBox {
//       label: "Country"
//       model: ["Australia", "Brazil", "Canada", "Denmark"]
//       onSelectionChanged: (i, item) => saveCountry(item)
//   }
//
//   // Object items with value/label:
//   ComboBox {
//       model: [
//           { label: "Administrator", value: "admin"  },
//           { label: "Editor",        value: "editor" },
//           { label: "Viewer",        value: "viewer" },
//       ]
//       placeholder: "Choose role…"
//       onSelectionChanged: (i, item) => setRole(item.value)
//   }
//
//   // Pre-selected, clearable, non-searchable:
//   ComboBox { currentIndex: 2; clearable: true; searchable: false }
Item {
    id: root

    property var    model:        []
    property int    currentIndex: -1
    property string placeholder:  "Select…"
    property bool   searchable:   true
    property bool   clearable:    false
    property string label:        ""
    property string helper:       ""
    property string errorText:    ""
    property bool   disabled:     false

    signal selectionChanged(int index, var item)

    implicitWidth:  260
    implicitHeight: _col.implicitHeight

    readonly property bool _hasError: root.errorText !== ""

    // Currently selected item
    readonly property var _selected: root.currentIndex >= 0 && root.currentIndex < root.model.length
                                     ? root.model[root.currentIndex]
                                     : null
    readonly property string _selectedLabel: {
        if (!_selected) return ""
        return typeof _selected === "string" ? _selected : (_selected.label ?? "")
    }

    // Filtered model
    property string _search: ""
    readonly property var _filtered: {
        var q = _search.toLowerCase()
        if (!root.searchable || q === "") return root.model
        return root.model.filter(function(item) {
            var label = typeof item === "string" ? item : (item.label ?? "")
            return label.toLowerCase().indexOf(q) >= 0
        })
    }

    // Index of item in filtered list
    function _filteredIndex(origIdx: var): var {
        var item = root.model[origIdx]
        return _filtered.indexOf(item)
    }

    // Find original index from filtered item
    function _origIndex(filteredItem: var): var {
        return root.model.indexOf(filteredItem)
    }

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.sp1

        Text {
            visible:        root.label !== ""
            text:           root.label
            color:          Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            font.weight:    Theme.weightMedium
        }

        // ── Trigger ───────────────────────────────────────────────────────────
        Rectangle {
            id:              _trigger
            Layout.fillWidth: true
            height:          40
            color:           root.disabled ? Theme.panel : Theme.surface
            radius:          Theme.radiusMd
            border.color:    root._hasError   ? Theme.error
                           : _popup.opened    ? Theme.primary
                           : Theme.border
            border.width:    _popup.opened || root._hasError ? 2 : 1
            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                enabled:      !root.disabled
                onClicked: {
                    root._search = ""
                    _searchInput.text = ""
                    _popup.open()
                    if (root.searchable) _searchInput.forceActiveFocus()
                }
            }

            RowLayout {
                anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp2 }
                spacing: Theme.sp2

                // Search input (visible when popup open and searchable)
                TextInput {
                    id:             _searchInput
                    visible:        _popup.opened && root.searchable
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    Layout.fillWidth: true
                    onTextChanged:  root._search = text

                    Keys.onEscapePressed: _popup.close()
                    Keys.onReturnPressed: {
                        if (root._filtered.length > 0) {
                            root.currentIndex = root._origIndex(root._filtered[0])
                            root.selectionChanged(root.currentIndex, root._filtered[0])
                            _popup.close()
                        }
                    }
                }

                // Display value (visible when popup closed or non-searchable)
                Text {
                    visible:          !(_popup.opened && root.searchable)
                    text:             root._selectedLabel !== "" ? root._selectedLabel : ""
                    color:            root.disabled ? Theme.textDisabled : Theme.textPrimary
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.textSm
                    Layout.fillWidth: true
                }

                // Placeholder
                Text {
                    visible: root._selectedLabel === "" && !(_popup.opened && root.searchable)
                    anchors.left: parent ? undefined : undefined
                    text:           root.placeholder
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    // Note: this overlaps TextInput/Text above; actual layout uses z or visibility
                }

                // Clear button
                Rectangle {
                    visible:  root.clearable && root.currentIndex >= 0
                    width: 20; height: 20; radius: 10
                    color: _clH.hovered ? Theme.hover : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _clH }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            mouse.accepted = true
                            root.currentIndex = -1
                            root.selectionChanged(-1, null)
                        }
                    }
                    Icon { anchors.centerIn: parent; name: Icons.x; size: 10; color: Theme.textSecondary }
                }

                Icon {
                    name:  _popup.opened ? Icons.caretUp : Icons.caretDown
                    size:  14; color: Theme.textSecondary
                    Behavior on name { }
                }
            }
        }

        // Helper / error
        Text {
            visible:        root.helper !== "" && !root._hasError
            text:           root.helper
            color:          Theme.textDisabled
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
        }
        Text {
            visible:        root._hasError
            text:           root.errorText
            color:          Theme.error
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
        }
    }

    // ── Popup ─────────────────────────────────────────────────────────────────
    QQC.Popup {
        id:          _popup
        parent:      _trigger
        y:           _trigger.height + Theme.sp1
        x:           0
        width:       _trigger.width
        padding:     Theme.sp1
        closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside
        focus:       !root.searchable

        enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durationFast } }
        exit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.durationFast } }

        background: Rectangle {
            color:        Theme.surface
            radius:       Theme.radiusMd
            border.color: Theme.border
            border.width: 1
        }

        contentItem: Column {
            // Empty state
            Item {
                visible: root._filtered.length === 0
                width:   _popup.width - Theme.sp2
                height:  48
                Text {
                    anchors.centerIn: parent
                    text:           "No results"
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                }
            }

            Repeater {
                model: root._filtered

                delegate: Rectangle {
                    id: _rq1
                    required property var modelData
                    required property int index

                    readonly property string _label: typeof modelData === "string" ? modelData : (modelData.label ?? "")
                    readonly property bool   _sel:   root._origIndex(modelData) === root.currentIndex

                    width:  _popup.width - Theme.sp2
                    height: 36; radius: Theme.radiusSm
                    color:  _sel ? Theme.primarySubtle
                          : _rH.hovered ? Theme.hover
                          : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _rH }

                    RowLayout {
                        anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }

                        Text {
                            text:             _rq1._label
                            color:            _rq1._sel ? Theme.primary : Theme.textPrimary
                            font.family:      Theme.fontFamily
                            font.pixelSize:   Theme.textSm
                            font.weight:      _rq1._sel ? Theme.weightMedium : Theme.weightRegular
                            Layout.fillWidth: true
                        }

                        Icon {
                            visible: _rq1._sel
                            name:    Icons.check; size: 14; color: Theme.primary
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var origIdx = root._origIndex(_rq1.modelData)
                            root.currentIndex = origIdx
                            root.selectionChanged(origIdx, _rq1.modelData)
                            _popup.close()
                        }
                    }
                }
            }
        }
    }
}
