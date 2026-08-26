pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

// Table with inline cell editing. Click a cell to edit it in place.
//
// Usage:
//   EditableTable {
//       columns: [
//           { key: "name",  label: "Name",   width: 160 },
//           { key: "email", label: "Email",  width: 200, editable: false },
//           { key: "role",  label: "Role",   width: 100 },
//       ]
//       rows: [
//           { name: "Alice", email: "alice@example.com", role: "Admin" },
//           { name: "Bob",   email: "bob@example.com",   role: "User"  },
//       ]
//       onCellEdited: (row, key, value) => myModel.update(row, key, value)
//   }
Item {
    id: root

    property var columns: []
    property var rows:    []

    signal cellEdited(int row, string key, string value)
    signal rowClicked(int row, var rowData)
    signal deleteRow(int row)

    property int  _editRow:  -1
    property string _editKey: ""
    property string _editVal: ""

    implicitWidth:  500
    implicitHeight: _header.height + _body.contentHeight + 2

    readonly property real _totalW: {
        var w = 0
        for (var i = 0; i < root.columns.length; i++) w += (root.columns[i].width ?? 120)
        return w
    }

    // ── Header ────────────────────────────────────────────────────────────────
    Rectangle {
        id:          _header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height:      36
        color:       Theme.panel
        border.color: Theme.border; border.width: 1
        radius:      Theme.radiusMd
        clip:        true

        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: Theme.sp2 }
            Repeater {
                model: root.columns
                delegate: Item {
                    id: _rq2
                    required property var modelData
                    width:  modelData.width ?? 120
                    height: _header.height

                    Text {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: Theme.sp3 }
                        text:           _rq2.modelData.label ?? _rq2.modelData.key ?? ""
                        color:          Theme.textSecondary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        font.weight:    Theme.weightSemibold
                    }

                    Rectangle {
                        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                        width: 1; color: Theme.border
                    }
                }
            }
        }
    }

    // ── Body ──────────────────────────────────────────────────────────────────
    ListView {
        id:    _body
        anchors {
            top:    _header.bottom
            left:   parent.left
            right:  parent.right
            bottom: parent.bottom
        }
        model:          root.rows
        clip:           true
        boundsBehavior: Flickable.StopAtBounds

        QQC.ScrollBar.vertical: QQC.ScrollBar {
            contentItem: Rectangle { radius: 3; color: Theme.borderStrong }
            background:  Rectangle { color: "transparent" }
        }

        delegate: Rectangle {
            id: _rq1
            required property var modelData
            required property int index

            readonly property bool _isEditing: root._editRow === index

            width:  Math.max(_body.width, root._totalW + Theme.sp2 * 2)
            height: 40
            color:  _rhov.containsMouse ? Theme.surfaceVariant : (index % 2 === 1 ? Theme.panel : "transparent")
            Behavior on color { ColorAnimation { duration: Theme.durationFast } }

            HoverHandler { id: _rhov }

            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 1; color: Theme.border
            }

            // Highlight row border when any cell in this row is being edited
            Rectangle {
                visible:      _isEditing
                anchors.fill: parent
                color:        "transparent"
                border.color: Theme.primary; border.width: 1
            }

            Row {
                anchors { left: parent.left; leftMargin: Theme.sp2; verticalCenter: parent.verticalCenter }

                Repeater {
                    model: root.columns
                    delegate: Item {
                        required property var modelData
                        required property int index

                        readonly property string _colKey:    modelData.key ?? ""
                        readonly property bool   _editable:  modelData.editable !== false
                        readonly property bool   _cellEdit:  root._editRow === parent.parent.index && root._editKey === _colKey

                        width:  modelData.width ?? 120
                        height: 40

                        Rectangle {
                            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                            width: 1; color: Theme.border
                        }

                        // Display text
                        Text {
                            visible:        !_cellEdit
                            anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp3; rightMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                            text:           {
                                var row = parent.parent.parent.modelData
                                row ? String(row[_colKey] ?? "") : ""
                            }
                            color:          Theme.textPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            elide:          Text.ElideRight
                        }

                        // Edit TextInput
                        Rectangle {
                            visible:      _cellEdit
                            anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp2; rightMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                            height:       28
                            radius:       Theme.radiusSm
                            color:        Theme.surface
                            border.color: Theme.primary; border.width: 1

                            TextInput {
                                id:         _ti
                                anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp2; rightMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                                text:       _cellEdit ? root._editVal : ""
                                color:      Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.textSm
                                clip:       true

                                onTextChanged: if (_cellEdit) root._editVal = text

                                Keys.onReturnPressed: _commitEdit()
                                Keys.onEscapePressed: { root._editRow = -1; root._editKey = "" }

                                function _commitEdit() {
                                    var rowIdx = root._editRow
                                    var key    = root._editKey
                                    var val    = root._editVal
                                    root._editRow = -1
                                    root._editKey = ""
                                    root.cellEdited(rowIdx, key, val)
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            visible:      _editable && !_cellEdit
                            cursorShape:  Qt.IBeamCursor
                            onClicked: {
                                var outerDelegate = parent.parent.parent
                                root._editRow = outerDelegate.index
                                root._editKey = _colKey
                                root._editVal = String((outerDelegate.modelData)[_colKey] ?? "")
                            }
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                visible:      false  // row click handled per cell; this is just for row signal
                onClicked:    root.rowClicked(_rq1.index, _rq1.modelData)
            }
        }
    }

    // Click outside to dismiss edit
    MouseArea {
        anchors.fill: parent
        z:            -1
        onClicked: {
            root._editRow = -1
            root._editKey = ""
        }
    }
}
