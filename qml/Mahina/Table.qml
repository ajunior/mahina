import QtQuick
import QtQuick.Layouts
import Mahina

// Sortable data table with fixed header and optional striped rows.
//
// Usage:
//   Table {
//       columns: [
//           { key: "name",  label: "Name",   width: 180, sortable: true },
//           { key: "role",  label: "Role",   width: 120                 },
//           { key: "email", label: "Email",               sortable: true },
//       ]
//       rows: [
//           { name: "Alice",   role: "Admin",  email: "alice@example.com"  },
//           { name: "Bob",     role: "Editor", email: "bob@example.com"    },
//       ]
//       sortKey: "name"
//       onSortChanged: (key, asc) => { sortKey = key; sortAscending = asc }
//   }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var    columns:       []
    property var    rows:          []
    property bool   striped:       false
    property string sortKey:       ""
    property bool   sortAscending: true

    // Max visible rows before internal scroll; 0 = show all
    property int    maxRows:  0

    signal sortChanged(string key, bool ascending)
    signal rowClicked(int index, var row)

    // ── Internal ─────────────────────────────────────────────────────────────
    readonly property real _headerH: 40
    readonly property real _rowH:    44

    // Compute pixel widths: fixed columns get their specified width;
    // flexible columns share the remainder equally.
    readonly property var _widths: {
        if (root.columns.length === 0) return []
        var fixedTotal = 0
        var flexCount  = 0
        for (var i = 0; i < root.columns.length; i++) {
            if (root.columns[i].width !== undefined) fixedTotal += root.columns[i].width
            else flexCount++
        }
        var flexW = flexCount > 0
                    ? Math.max(60, (root.width - fixedTotal) / flexCount)
                    : 0
        return root.columns.map(function(c) {
            return c.width !== undefined ? c.width : flexW
        })
    }

    // Sorted row list
    readonly property var _sortedRows: {
        if (root.sortKey === "" || root.rows.length === 0) return root.rows
        var sorted = root.rows.slice()
        var key = root.sortKey
        var asc = root.sortAscending
        sorted.sort(function(a, b) {
            var av = a[key] ?? "", bv = b[key] ?? ""
            if (av < bv) return asc ? -1 : 1
            if (av > bv) return asc ?  1 : -1
            return 0
        })
        return sorted
    }

    readonly property int _visibleRows: root.maxRows > 0
                                        ? Math.min(root.maxRows, root._sortedRows.length)
                                        : root._sortedRows.length

    implicitWidth:  300
    implicitHeight: root._headerH + root._visibleRows * root._rowH

    // ── Header ────────────────────────────────────────────────────────────────
    Rectangle {
        id:    _header
        width: parent.width
        height: root._headerH
        color: Theme.panel
        radius: Theme.radiusMd

        // Clip bottom corners flat (header is above the list)
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: parent.radius
            color:  parent.color
        }

        Row {
            anchors.fill: parent

            Repeater {
                model: root.columns

                delegate: Item {
                    id: _rq1
                    required property var modelData
                    required property int index

                    width:  root._widths[index] ?? 0
                    height: root._headerH

                    RowLayout {
                        anchors {
                            fill:        parent
                            leftMargin:  Theme.sp3
                            rightMargin: Theme.sp2
                        }
                        spacing: Theme.sp1

                        Text {
                            text:             _rq1.modelData.label ?? _rq1.modelData.key ?? ""
                            color:            Theme.textSecondary
                            font.family:      Theme.fontFamily
                            font.pixelSize:   Theme.textXs
                            font.weight:      Theme.weightSemibold
                            Layout.fillWidth: true
                            elide:            Text.ElideRight
                        }

                        // Sort indicator
                        Icon {
                            visible: (_rq1.modelData.sortable === true) && root.sortKey === (_rq1.modelData.key ?? "")
                            name:    root.sortAscending ? Icons.arrowUp : Icons.arrowDown
                            size:    12
                            color:   Theme.primary
                        }
                    }

                    // Hover tint + click for sortable columns
                    Rectangle {
                        anchors.fill: parent
                        color:        _rq1.modelData.sortable === true && _hHover.containsMouse
                                      ? Qt.rgba(0,0,0,0.04) : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    }

                    HoverHandler { id: _hHover; enabled: _rq1.modelData.sortable === true }
                    MouseArea {
                        anchors.fill: parent
                        enabled:      _rq1.modelData.sortable === true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            var key = _rq1.modelData.key ?? ""
                            if (root.sortKey === key)
                                root.sortAscending = !root.sortAscending
                            else {
                                root.sortKey = key
                                root.sortAscending = true
                            }
                            root.sortChanged(root.sortKey, root.sortAscending)
                        }
                    }

                    // Column divider
                    Rectangle {
                        visible: _rq1.index < root.columns.length - 1
                        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                        anchors.topMargin:    8
                        anchors.bottomMargin: 8
                        width: 1
                        color: Theme.border
                    }
                }
            }
        }
    }

    // ── Border + rows ─────────────────────────────────────────────────────────
    Rectangle {
        anchors {
            top:    _header.bottom
            left:   parent.left
            right:  parent.right
            bottom: parent.bottom
        }
        color:        Theme.surface
        border.color: Theme.border
        border.width: 1
        radius:       Theme.radiusMd
        clip:         true

        // Clip top corners flat (list sits below the header)
        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: parent.radius
            color:  Theme.surface
        }

        ListView {
            id:           _list
            anchors.fill: parent
            model:        root._sortedRows
            clip:         true
            interactive:  root.maxRows > 0 && root._sortedRows.length > root.maxRows
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                id:       _rowItem
                required property var modelData   // the row object
                required property int index

                width:  _list.width
                height: root._rowH

                // Row background
                Rectangle {
                    anchors.fill: parent
                    color: _rowHov.containsMouse    ? Theme.panel
                         : root.striped && _rowItem.index % 2 === 1 ? Theme.surfaceVariant
                         : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                }

                // Bottom border
                Rectangle {
                    visible: _rowItem.index < root._sortedRows.length - 1
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: 1; color: Theme.border
                }

                HoverHandler { id: _rowHov }
                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    root.rowClicked(_rowItem.index, _rowItem.modelData)
                }

                // Cells
                Row {
                    anchors.fill: parent

                    Repeater {
                        model: root.columns

                        delegate: Item {
                            id: _rq2
                            required property var modelData   // column def
                            required property int index       // column index

                            width:  root._widths[index] ?? 0
                            height: root._rowH

                            Text {
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left:           parent.left
                                    leftMargin:     Theme.sp3
                                    right:          parent.right
                                    rightMargin:    Theme.sp2
                                }
                                // Access row data via the named outer delegate
                                text:           String(_rowItem.modelData[_rq2.modelData.key] ?? "")
                                color:          Theme.textPrimary
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textSm
                                elide:          Text.ElideRight
                                horizontalAlignment: {
                                    switch (_rq2.modelData.align) {
                                        case "center": return Text.AlignHCenter
                                        case "right":  return Text.AlignRight
                                        default:       return Text.AlignLeft
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
