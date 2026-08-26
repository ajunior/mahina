pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as QQC
import Mahina

// Advanced data table with sortable columns, row selection, and sticky header.
//
// Usage:
//   DataGrid {
//       columns: [
//           { key: "name",   label: "Name",   width: 160 },
//           { key: "email",  label: "Email",  width: 200 },
//           { key: "role",   label: "Role",   width: 100 },
//       ]
//       rows: [
//           { name: "Alice Chen", email: "alice@co.com", role: "Admin"  },
//           { name: "Bob Torres", email: "bob@co.com",   role: "Member" },
//       ]
//       onRowSelected: (row) => detail.show(row)
//   }
Item {
    id: root

    property var columns:     []
    property var rows:        []
    property int selectedRow: -1
    property string sortKey:  ""
    property bool   sortAsc:  true

    signal rowSelected(var row)
    signal sortChanged(string key, bool ascending)

    implicitWidth:  _totalW
    implicitHeight: 400

    readonly property int rowH:    44
    readonly property int headerH: 40

    readonly property int _totalW: {
        var w = 0
        for (var i = 0; i < columns.length; i++) w += columns[i].width || 100
        return Math.max(w, 1)
    }

    readonly property var _sortedRows: {
        if (root.sortKey === "") return root.rows.slice()
        var sk = root.sortKey, asc = root.sortAsc
        return root.rows.slice().sort(function(a, b) {
            var av = a[sk] ?? "", bv = b[sk] ?? ""
            if (av < bv) return asc ? -1 : 1
            if (av > bv) return asc ?  1 : -1
            return 0
        })
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // Sticky header
        Rectangle {
            width:  parent.width; height: root.headerH
            color:  Theme.panel; z: 2
            Rectangle { width: parent.width; height: 1; anchors.bottom: parent.bottom; color: Theme.border }

            Row {
                anchors.fill: parent
                Repeater {
                    model: root.columns
                    delegate: Rectangle {
                        id: _rq1
                        required property var  modelData
                        required property int  index
                        width:  modelData.width || 100; height: root.headerH
                        color:  _hH.hovered ? Theme.surfaceVariant : Theme.panel
                        HoverHandler { id: _hH }
                        Rectangle { width: 1; height: parent.height; anchors.right: parent.right; color: Theme.border; opacity: 0.5 }

                        Row {
                            anchors { fill: parent; leftMargin: Theme.sp3 }
                            spacing: Theme.sp1
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text:           _rq1.modelData.label || ""
                                color:          Theme.textPrimary
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textXs
                                font.weight:    Theme.weightSemibold
                                elide:          Text.ElideRight
                                width:          parent.width - 18
                            }
                            Text {
                                visible:        root.sortKey === _rq1.modelData.key
                                anchors.verticalCenter: parent.verticalCenter
                                text:           root.sortAsc ? "↑" : "↓"
                                color:          Theme.primary
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textXs
                            }
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.sortKey === _rq1.modelData.key) root.sortAsc = !root.sortAsc
                                else { root.sortKey = _rq1.modelData.key; root.sortAsc = true }
                                root.sortChanged(root.sortKey, root.sortAsc)
                            }
                        }
                    }
                }
            }
        }

        // Rows
        QQC.ScrollView {
            width:  parent.width
            height: root.height - root.headerH
            clip:   true
            contentWidth: root._totalW

            Column {
                width: root._totalW
                spacing: 0

                Repeater {
                    model: root._sortedRows
                    delegate: Rectangle {
                        id:    _rowRect
                        required property var  modelData
                        required property int  index

                        property bool isSelected: root.selectedRow === index

                        width:  root._totalW; height: root.rowH
                        color:  isSelected          ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.1)
                              : _rowH.hovered ? Theme.panel
                              : index % 2 === 0    ? Theme.surface
                              : Theme.background
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        HoverHandler { id: _rowH }

                        Rectangle { width: 3; height: parent.height; color: Theme.primary; visible: _rowRect.isSelected }
                        Rectangle { width: parent.width; height: 1; anchors.bottom: parent.bottom; color: Theme.border; opacity: 0.5 }

                        Row {
                            anchors { fill: parent; leftMargin: 3 }
                            Repeater {
                                model: root.columns
                                delegate: Item {
                                    id: _rq2
                                    required property var  modelData   // column def
                                    width:  modelData.width || 100; height: root.rowH

                                    Text {
                                        anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp2 }
                                        verticalAlignment: Text.AlignVCenter
                                        text:           {
                                            var v = _rowRect.modelData[_rq2.modelData.key]
                                            return v !== undefined ? String(v) : ""
                                        }
                                        color:          Theme.textPrimary
                                        font.family:    Theme.fontFamily
                                        font.pixelSize: Theme.textSm
                                        elide:          Text.ElideRight
                                    }
                                    Rectangle { width: 1; height: parent.height; anchors.right: parent.right; color: Theme.border; opacity: 0.3 }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: { root.selectedRow = _rowRect.index; root.rowSelected(_rowRect.modelData) }
                        }
                    }
                }
            }
        }
    }
}
