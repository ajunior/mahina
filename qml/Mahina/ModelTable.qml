pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import QtQml.Models
import Mahina

// Themed table backed by a QAbstractItemModel (or QAbstractTableModel).
// Use this instead of Table when your data lives in a C++ model —
// large result sets stay in the model; nothing is copied into JS arrays.
//
// ── Model contract ────────────────────────────────────────────────────────────
// The cell delegate binds model roles by name, so roleNames() MUST provide:
//
//   "display"  (QString) — the cell text; never return a null QVariant here
//   "isNull"   (bool)    — true when the cell holds no value
//
// Both are required properties: a model missing either fails to instantiate the
// delegate, and the table renders empty with "Error incubating delegate" on the
// console. "isNull" is what lets a NULL render distinctly (italic, dimmed,
// "NULL") from a present-but-empty string, so the two are never confused.
//
// This is why QML-side TableModel cannot drive this component —
// TableModelColumn only maps Qt's built-in item roles and cannot supply
// "isNull". See example/DemoTableModel.{h,cpp} for a minimal conforming model.
//
// Optional:
//   headerData(section, Qt::Horizontal, Qt::DisplayRole) — column titles
//   Q_INVOKABLE sort(int column, Qt::SortOrder)          — enables header sorting
//
// Usage:
//   ModelTable {
//       model:      resultModel          // any conforming QAbstractItemModel
//       rowHeight:  32
//       striped:    true
//       onRowClicked: (row) => console.log("selected row", row)
//   }
//
// Selected row index:   modelTable.selectedRow  (-1 = none)
// Clear selection:      modelTable.clearSelection()
Item {
    id: root

    property var  model:          null
    property bool showHeader:     true
    property bool striped:        true
    property real rowHeight:      36
    property real headerHeight:   38
    property real minColumnWidth: 80

    readonly property int selectedRow: _sel.hasSelection
        ? _sel.selectedIndexes[0].row : -1

    property int  _sortCol:   -1
    property bool _sortAsc:   true
    property var  _colWidths: ({})   // { colIndex: pixelWidth } — user-dragged overrides

    onModelChanged: {
        root._sortCol   = -1
        root._sortAsc   = true
        root._colWidths = {}
        Qt.callLater(() => _tv.forceLayout())
    }

    function _relayout(): void { _tv.forceLayout() }

    signal rowClicked(int row)
    signal cellClicked(int row, int column, string value)
    signal cellDoubleClicked(int row, int column, string value)

    function clearSelection(): void {
        _sel.clearSelection()
    }

    // ── Selection model ───────────────────────────────────────────────────────
    ItemSelectionModel {
        id:    _sel
        model: root.model
    }

    // ── Header ────────────────────────────────────────────────────────────────
    QQC.HorizontalHeaderView {
        id:       _header
        visible:  root.showHeader
        syncView: _tv
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height:   root.showHeader ? root.headerHeight : 0
        clip:     true

        delegate: Rectangle {
            id: _hCell
            required property int    column
            required property string display

            // Capture outer root for JS handlers (required props isolate JS scope)
            readonly property var _table: root

            implicitHeight: root.headerHeight
            color:          _hHover.hovered ? Theme.surfaceVariant : Theme.panel

            Behavior on color { ColorAnimation { duration: 80 } }

            // Bottom border
            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 1; color: Theme.border
            }
            // Column separator
            Rectangle {
                visible: _hCell.column > 0
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                width: 1; color: Theme.border
            }

            // Sort indicator
            Text {
                id: _sortArrow
                visible: _hCell._table._sortCol === _hCell.column
                anchors { right: parent.right; rightMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                text:           _hCell._table._sortAsc ? "↑" : "↓"
                color:          Theme.primary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Theme.weightSemibold
            }

            Text {
                anchors {
                    left: parent.left
                    right: _sortArrow.visible ? _sortArrow.left : parent.right
                    verticalCenter: parent.verticalCenter
                }
                leftPadding:    Theme.sp3
                rightPadding:   Theme.sp1
                text:           _hCell.display
                color:          _hCell._table._sortCol === _hCell.column
                                ? Theme.textPrimary : Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Theme.weightSemibold
                elide:          Text.ElideRight
            }

            HoverHandler { id: _hHover }

            // Sort click — full cell, lower z than resize handle
            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked: {
                    const col = _hCell.column
                    const t   = _hCell._table
                    if (t._sortCol === col) {
                        if (t._sortAsc) {
                            t._sortAsc = false
                            if (t.model && t.model.sort) t.model.sort(col, Qt.DescendingOrder)
                        } else {
                            t._sortCol = -1
                            if (t.model && t.model.clearSort) t.model.clearSort()
                        }
                    } else {
                        t._sortCol = col
                        t._sortAsc = true
                        if (t.model && t.model.sort) t.model.sort(col, Qt.AscendingOrder)
                    }
                }
            }

            // Resize handle — right 6 px, higher z than sort area
            MouseArea {
                id: _resizeHandle
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                width: 6
                cursorShape: Qt.SizeHorCursor
                // Without this containsMouse never becomes true, and the resize
                // indicator below it stayed transparent for the handle's whole life.
                hoverEnabled: true

                property real _startX: 0
                property real _startW: 0

                onPressed: (mouse) => {
                    _startX = mapToItem(null, mouse.x, 0).x
                    _startW = _hCell.width
                }
                onPositionChanged: (mouse) => {
                    if (!_resizeHandle.pressed) return
                    const t      = _hCell._table
                    const delta  = mapToItem(null, mouse.x, 0).x - _resizeHandle._startX
                    const newW   = Math.max(t.minColumnWidth, _resizeHandle._startW + delta)
                    const cw     = Object.assign({}, t._colWidths)
                    cw[_hCell.column] = newW
                    t._colWidths = cw
                    t._relayout()
                }

                // Subtle resize indicator line on hover
                Rectangle {
                    anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                    width: 2
                    color: _resizeHandle.containsMouse || _resizeHandle.pressed
                           ? Theme.primary : "transparent"
                    opacity: 0.6
                    Behavior on color { ColorAnimation { duration: 80 } }
                }
            }
        }
    }

    // ── Table ─────────────────────────────────────────────────────────────────
    // Row under the pointer, or -1. Held on the root rather than per cell so that
    // every cell of the same row lights up together, and so that moving sideways
    // between two cells of one row cannot leave the highlight behind: each cell
    // only ever *sets* this, and the handler on the view below is what clears it
    // when the pointer leaves the table.
    property int _hoverRow: -1

    TableView {
        id: _tv
        anchors {
            top:    root.showHeader ? _header.bottom : parent.top
            left:   parent.left
            right:  parent.right
            bottom: parent.bottom
        }
        clip:            true
        model:           root.model
        selectionModel:  _sel
        boundsBehavior:  Flickable.StopAtBounds

        // Not blocking, so the per-cell handlers below still see the pointer; this
        // one exists only to notice that it has left the table entirely.
        HoverHandler {
            id: _tvHover
            onHoveredChanged: if (!_tvHover.hovered) root._hoverRow = -1
        }

        rowHeightProvider: function() { return root.rowHeight }

        columnWidthProvider: function(col) {
            if (root._colWidths[col]) return root._colWidths[col]
            if (_tv.columns <= 0) return root.minColumnWidth
            const even = _tv.width / _tv.columns
            return Math.max(root.minColumnWidth, even)
        }

        QQC.ScrollBar.vertical: QQC.ScrollBar {
            policy: QQC.ScrollBar.AsNeeded
            contentItem: Rectangle { radius: 3; color: Theme.textDisabled; opacity: 0.6 }
            background:  Rectangle { color: "transparent" }
        }
        QQC.ScrollBar.horizontal: QQC.ScrollBar {
            policy: QQC.ScrollBar.AsNeeded
            contentItem: Rectangle { radius: 3; color: Theme.textDisabled; opacity: 0.6 }
            background:  Rectangle { color: "transparent" }
        }

        delegate: Rectangle {
            id: _cell
            required property int    row
            required property int    column
            required property string display
            required property bool   selected
            required property bool   isNull

            implicitHeight: root.rowHeight

            color: _cell.selected
                ? Qt.rgba(Qt.color(Theme.primary).r,
                          Qt.color(Theme.primary).g,
                          Qt.color(Theme.primary).b, 0.12)
                : (root.striped && _cell.row % 2 === 1)
                    ? Theme.surfaceVariant
                    : Theme.surface

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }

            HoverHandler {
                id: _cellHover
                onHoveredChanged: if (_cellHover.hovered) root._hoverRow = _cell.row
            }

            // Row hover wash. A translucent overlay rather than another value for
            // `color` above: the cell's own colour carries the zebra stripe and the
            // selection tint, and an opaque hover would erase both.
            Rectangle {
                anchors.fill: parent
                visible: root._hoverRow === _cell.row
                color:   Theme.hover
            }

            // Row border
            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 1; color: Theme.border; opacity: 0.5
            }
            // Column separator
            Rectangle {
                visible: _cell.column > 0
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                width: 1; color: Theme.border; opacity: 0.4
            }

            Text {
                anchors {
                    left: parent.left; right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                leftPadding:     Theme.sp3
                text:            _cell.isNull ? "NULL" : _cell.display
                color:           _cell.isNull ? Theme.textDisabled : Theme.textPrimary
                font.family:     _cell.isNull ? Theme.fontFamily : Theme.fontFamilyMono
                font.pixelSize:  Theme.textSm
                font.italic:     _cell.isNull
                elide:           Text.ElideRight
            }

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked: {
                    _sel.setCurrentIndex(
                        root.model.index(_cell.row, 0),
                        ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Rows
                    )
                    root.rowClicked(_cell.row)
                    root.cellClicked(_cell.row, _cell.column, _cell.display)
                }
                onDoubleClicked: root.cellDoubleClicked(_cell.row, _cell.column, _cell.display)
            }
        }
    }
}
