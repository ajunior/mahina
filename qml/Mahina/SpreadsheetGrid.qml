import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

Item {
    id: root

    property int rowCount:    10
    property int colCount:    8
    property int rowHeight:   28
    property int colWidth:    90
    property int headerSize:  28
    property var cellValues:  ({})  // key = "row,col", value = string

    property int activeRow: -1
    property int activeCol: -1

    signal cellEdited(int row, int col, string value)
    signal selectionChanged(int row, int col)

    implicitWidth:  colCount * colWidth + headerSize
    implicitHeight: rowCount * rowHeight + headerSize

    function _key(r, c) { return r + "," + c }
    function _colLetter(c) {
        var s = ""
        var n = c + 1
        while (n > 0) {
            s = String.fromCharCode(65 + (n - 1) % 26) + s
            n = Math.floor((n - 1) / 26)
        }
        return s
    }

    Rectangle {
        anchors.fill: parent
        color:  Theme.surface
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusMd
        clip: true

        // Corner cell
        Rectangle {
            x: 0; y: 0; width: root.headerSize; height: root.headerSize
            color: Theme.panel
            border.color: Theme.border; border.width: 1
            z: 3
        }

        // Column headers (horizontal)
        Flickable {
            id:    _colHdrFlick
            x:     root.headerSize
            y:     0
            width: root.width - root.headerSize
            height: root.headerSize
            contentX: _cellFlick.contentX
            contentWidth: root.colCount * root.colWidth
            contentHeight: root.headerSize
            interactive: false
            clip: true
            z: 2

            Row {
                Repeater {
                    model: root.colCount
                    delegate: Rectangle {
                        id: _rq1
                        required property int index
                        width: root.colWidth; height: root.headerSize
                        color: root.activeCol === index ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.10) : Theme.panel
                        border.color: Theme.border; border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text:  root._colLetter(_rq1.index)
                            color: root.activeCol === _rq1.index ? Theme.primary : Theme.textSecondary
                            font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium }
                        }
                    }
                }
            }
        }

        // Row headers (vertical)
        Flickable {
            id:    _rowHdrFlick
            x:     0
            y:     root.headerSize
            width: root.headerSize
            height: root.height - root.headerSize
            contentY: _cellFlick.contentY
            contentWidth:  root.headerSize
            contentHeight: root.rowCount * root.rowHeight
            interactive: false
            clip: true
            z: 2

            Column {
                Repeater {
                    model: root.rowCount
                    delegate: Rectangle {
                        id: _rq2
                        required property int index
                        width: root.headerSize; height: root.rowHeight
                        color: root.activeRow === index ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.10) : Theme.panel
                        border.color: Theme.border; border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text:  (_rq2.index + 1).toString()
                            color: root.activeRow === _rq2.index ? Theme.primary : Theme.textSecondary
                            font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium }
                        }
                    }
                }
            }
        }

        // Cell grid
        Flickable {
            id:    _cellFlick
            x:     root.headerSize
            y:     root.headerSize
            width: root.width - root.headerSize
            height: root.height - root.headerSize
            contentWidth:  root.colCount * root.colWidth
            contentHeight: root.rowCount * root.rowHeight
            clip: true
            QQC.ScrollBar.vertical:   QQC.ScrollBar {}
            QQC.ScrollBar.horizontal: QQC.ScrollBar {}

            Grid {
                rows:    root.rowCount
                columns: root.colCount

                Repeater {
                    model: root.rowCount * root.colCount
                    delegate: Rectangle {
                        required property int index
                        property int r: Math.floor(index / root.colCount)
                        property int c: index % root.colCount
                        property bool isActive: root.activeRow === r && root.activeCol === c

                        width:  root.colWidth
                        height: root.rowHeight
                        color:  isActive
                                ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.06)
                                : (r % 2 === 0 ? Theme.surface : Theme.surfaceVariant)
                        border.color: isActive ? Theme.primary : Theme.border
                        border.width: isActive ? 2 : 1
                        clip: true

                        // Display text (hidden when editing)
                        Text {
                            visible: !_cellEdit.activeFocus || !isActive
                            anchors { left: parent.left; right: parent.right; leftMargin: 6; rightMargin: 4; verticalCenter: parent.verticalCenter }
                            text:  root.cellValues[root._key(r, c)] || ""
                            color: Theme.textPrimary
                            font { family: Theme.fontFamily; pixelSize: Theme.textSm }
                            elide: Text.ElideRight
                        }

                        // Edit input
                        TextInput {
                            id:    _cellEdit
                            visible: isActive
                            anchors { fill: parent; leftMargin: 6; rightMargin: 4 }
                            verticalAlignment: TextInput.AlignVCenter
                            text:  root.cellValues[root._key(r, c)] || ""
                            color: Theme.textPrimary
                            font { family: Theme.fontFamily; pixelSize: Theme.textSm }
                            selectByMouse: true

                            onEditingFinished: {
                                var vals = Object.assign({}, root.cellValues)
                                vals[root._key(r, c)] = text
                                root.cellValues = vals
                                root.cellEdited(r, c, text)
                            }

                            Keys.onPressed: (e) => {
                                if (e.key === Qt.Key_Tab) {
                                    e.accepted = true
                                    if (c + 1 < root.colCount) { root.activeRow = r; root.activeCol = c + 1 }
                                    else if (r + 1 < root.rowCount) { root.activeRow = r + 1; root.activeCol = 0 }
                                }
                                if (e.key === Qt.Key_Return || e.key === Qt.Key_Down) {
                                    e.accepted = true
                                    if (r + 1 < root.rowCount) { root.activeRow = r + 1; root.activeCol = c }
                                }
                                if (e.key === Qt.Key_Escape) {
                                    e.accepted = true
                                    text = root.cellValues[root._key(r, c)] || ""
                                    root.activeRow = -1; root.activeCol = -1
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.activeRow = r; root.activeCol = c
                                root.selectionChanged(r, c)
                            }
                            onDoubleClicked: {
                                root.activeRow = r; root.activeCol = c
                                _cellEdit.forceActiveFocus()
                                _cellEdit.selectAll()
                            }
                        }
                    }
                }
            }
        }
    }
}
