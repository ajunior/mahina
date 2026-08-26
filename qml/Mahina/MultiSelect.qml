pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Multi-value picker: select multiple options from a dropdown, shown as chips.
//
// Usage:
//   MultiSelect {
//       label: "Tags"
//       model: ["Design", "Engineering", "Marketing", "Product", "Sales"]
//       onSelectionChanged: (items) => saveTags(items)
//   }
//
//   MultiSelect {
//       model: [
//           { label: "Admin",  value: "admin"  },
//           { label: "Editor", value: "editor" },
//       ]
//       maxSelections: 2
//   }
Item {
    id: root

    property var    model:         []
    property var    selectedIndices: []   // array of int
    property int    maxSelections: 0     // 0 = unlimited
    property string placeholder:   "Select options…"
    property string label:         ""
    property string helper:        ""
    property string errorText:     ""
    property bool   disabled:      false

    signal selectionChanged(var selectedItems)

    implicitWidth:  300
    implicitHeight: _col.implicitHeight

    readonly property bool _hasError: root.errorText !== ""
    readonly property bool _full:     root.maxSelections > 0 && root.selectedIndices.length >= root.maxSelections

    function _label(item: var): var { return typeof item === "string" ? item : (item.label ?? "") }

    function _toggleIndex(i: var): var {
        var arr = root.selectedIndices.slice()
        var pos = arr.indexOf(i)
        if (pos >= 0) {
            arr.splice(pos, 1)
        } else if (!root._full) {
            arr.push(i)
        }
        root.selectedIndices = arr
        root.selectionChanged(arr.map(function(idx) { return root.model[idx] }))
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

        // Trigger
        Rectangle {
            id:              _trigger
            Layout.fillWidth: true
            height:          Math.max(40, _chips.implicitHeight + Theme.sp2 * 2)
            color:           root.disabled ? Theme.panel : Theme.surface
            radius:          Theme.radiusMd
            border.color:    root._hasError ? Theme.error
                           : _popup.opened  ? Theme.primary
                           : Theme.border
            border.width:    _popup.opened || root._hasError ? 2 : 1
            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                enabled: !root.disabled
                onClicked: _popup.open()
            }

            // Chips
            Flow {
                id:     _chips
                anchors { fill: parent; margins: Theme.sp2; rightMargin: Theme.sp8 }
                spacing: Theme.sp1

                // Placeholder
                Text {
                    visible:        root.selectedIndices.length === 0
                    text:           root.placeholder
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    height:         24; verticalAlignment: Text.AlignVCenter
                }

                Repeater {
                    model: root.selectedIndices
                    delegate: Rectangle {
                        id: _rq2
                        required property int modelData  // the selected index

                        height: 24; radius: Theme.radiusFull
                        width:  _cRow.implicitWidth + Theme.sp2 * 2
                        color:  Theme.primarySubtle
                        border.color: Theme.primary; border.width: 1

                        Row {
                            id:               _cRow
                            anchors.centerIn: parent
                            spacing:          Theme.sp1

                            Text {
                                text:           root._label(root.model[_rq2.modelData])
                                color:          Theme.primary
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textXs
                                font.weight:    Theme.weightMedium
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 14; height: 14; radius: 7
                                anchors.verticalCenter: parent.verticalCenter
                                color: _cxH.containsMouse ? Theme.primary : "transparent"
                                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                                HoverHandler { id: _cxH }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: (mouse) => { mouse.accepted = true; root._toggleIndex(_rq2.modelData) }
                                }
                                Icon { anchors.centerIn: parent; name: Icons.x; size: 8; color: _cxH.containsMouse ? "#ffffff" : Theme.primary }
                            }
                        }
                    }
                }
            }

            // Caret
            Icon {
                anchors { right: parent.right; rightMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                name:  _popup.opened ? Icons.caretUp : Icons.caretDown
                size:  14; color: Theme.textSecondary
            }
        }

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

        enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durationFast } }
        exit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.durationFast } }

        background: Rectangle {
            color:        Theme.surface
            radius:       Theme.radiusMd
            border.color: Theme.border
            border.width: 1
        }

        contentItem: Column {
            Repeater {
                model: root.model

                delegate: Rectangle {
                    id: _rq1
                    required property var modelData
                    required property int index

                    readonly property bool _sel: root.selectedIndices.indexOf(index) >= 0
                    readonly property bool _dis: !_sel && root._full

                    width:  _popup.width - Theme.sp2
                    height: 36; radius: Theme.radiusSm
                    color:  _sel ? Theme.primarySubtle
                          : _dis ? "transparent"
                          : _rH.containsMouse ? Theme.panel
                          : "transparent"
                    opacity: _dis ? 0.4 : 1.0
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _rH; enabled: !_dis }

                    RowLayout {
                        anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }

                        Text {
                            text:             root._label(_rq1.modelData)
                            color:            _sel ? Theme.primary : Theme.textPrimary
                            font.family:      Theme.fontFamily
                            font.pixelSize:   Theme.textSm
                            font.weight:      _sel ? Theme.weightMedium : Theme.weightRegular
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 18; height: 18; radius: 4
                            color:        _sel ? Theme.primary : "transparent"
                            border.color: _sel ? Theme.primary : Theme.border
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                            Icon { visible: _sel; anchors.centerIn: parent; name: Icons.check; size: 11; color: "#ffffff" }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        enabled: !_dis || _sel
                        onClicked: root._toggleIndex(_rq1.index)
                    }
                }
            }
        }
    }
}
