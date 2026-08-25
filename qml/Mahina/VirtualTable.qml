import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    // tableColumns: [{id, label, width}]
    property var tableColumns: []
    property int rowCount:     0
    property int rowHeight:    36
    property int headerHeight: 36

    // getCellData(row, colId) → string | number
    property var getCellData:  null

    // sortColId, sortAsc for display only (caller must re-sort data)
    property string sortColId: ""
    property bool   sortAsc:   true

    signal rowClicked(int row)
    signal headerClicked(string colId)
    signal cellClicked(int row, string colId)

    implicitWidth:  600
    implicitHeight: 400

    readonly property int _totalW: {
        var w = 0
        for (var i = 0; i < root.tableColumns.length; i++) w += (root.tableColumns[i].width || 100)
        return w
    }

    Rectangle {
        anchors.fill: parent
        color:  Theme.surface
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusMd
        clip: true

        Column {
            anchors.fill: parent
            spacing: 0

            // Fixed header
            Rectangle {
                id:    _header
                width: parent.width; height: root.headerHeight
                color: Theme.panel
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.border }
                clip: true

                Row {
                    id:    _headerRow
                    x:     -_dataFlick.contentX
                    height: parent.height

                    Repeater {
                        model: root.tableColumns
                        delegate: Rectangle {
                            id: _rq1
                            required property var  modelData
                            required property int  index
                            width:  modelData.width || 100; height: root.headerHeight
                            color:  _hdrH.hovered ? Theme.panel : "transparent"
                            HoverHandler { id: _hdrH }
                            Rectangle { anchors { right: parent.right; top: parent.top; bottom: parent.bottom } width: 1; color: Theme.border }

                            Row {
                                anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                                spacing: 4
                                Text {
                                    text:  _rq1.modelData.label || _rq1.modelData.id || ""
                                    color: root.sortColId === _rq1.modelData.id ? Theme.primary : Theme.textPrimary
                                    font { family: Theme.fontFamily; pixelSize: Theme.textSm; weight: Font.Medium }
                                    elide: Text.ElideRight
                                    width: parent.width - (root.sortColId === _rq1.modelData.id ? 12 : 0) - Theme.sp3
                                }
                                Text {
                                    visible: root.sortColId === _rq1.modelData.id
                                    text:  root.sortAsc ? "▴" : "▾"
                                    color: Theme.primary; font.pixelSize: 9
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: root.headerClicked(_rq1.modelData.id || "")
                            }
                        }
                    }
                }
            }

            // Virtualized rows
            Flickable {
                id:           _dataFlick
                width:        parent.width
                height:       root.height - root.headerHeight
                contentWidth: Math.max(parent.width, root._totalW)
                contentHeight: root.rowCount * root.rowHeight
                clip: true
                QQC.ScrollBar.vertical:   QQC.ScrollBar {}
                QQC.ScrollBar.horizontal: QQC.ScrollBar {}

                // Only render visible rows
                readonly property int _firstRow: Math.max(0, Math.floor(contentY / root.rowHeight))
                readonly property int _lastRow:  Math.min(root.rowCount - 1, Math.ceil((contentY + height) / root.rowHeight))

                Item {
                    width:  root._totalW
                    height: root.rowCount * root.rowHeight

                    Repeater {
                        model: Math.max(0, _dataFlick._lastRow - _dataFlick._firstRow + 1)
                        delegate: Item {
                            required property int index
                            property int rowIdx: _dataFlick._firstRow + index
                            x:      0
                            y:      rowIdx * root.rowHeight
                            width:  root._totalW
                            height: root.rowHeight

                            Rectangle {
                                x: 0; width: root._totalW
                                anchors { bottom: parent.bottom }
                                height: 1; color: Theme.border
                            }

                            Row {
                            Repeater {
                                model: root.tableColumns
                                delegate: Rectangle {
                                    id: _rq2
                                    required property var  modelData
                                    required property int  index
                                    width:  modelData.width || 100
                                    height: root.rowHeight
                                    color:  _cellH.hovered ? Theme.panel : (rowIdx % 2 === 0 ? "transparent" : Theme.surfaceVariant)
                                    HoverHandler { id: _cellH }
                                    Rectangle { anchors { right: parent.right; top: parent.top; bottom: parent.bottom } width: 1; color: Theme.border; opacity: 0.5 }

                                    Text {
                                        anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp3; rightMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                                        text:  {
                                            if (!root.getCellData) return ""
                                            var v = root.getCellData(rowIdx, _rq2.modelData.id || "")
                                            return v !== undefined && v !== null ? v.toString() : ""
                                        }
                                        color: Theme.textPrimary
                                        font { family: Theme.fontFamily; pixelSize: Theme.textSm }
                                        elide: Text.ElideRight
                                    }

                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: root.cellClicked(rowIdx, _rq2.modelData.id || "")
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
}
