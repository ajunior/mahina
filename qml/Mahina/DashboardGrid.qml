pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Responsive CSS-grid-like layout for dashboard cards.
// Children are placed in a fixed-column grid; each child can span multiple columns.
//
// Usage:
//   DashboardGrid {
//       columns: 3; cellHeight: 160; gap: 12
//       KPICard { DashboardGrid.colSpan: 1 }
//       KPICard { DashboardGrid.colSpan: 2 }
//   }
Item {
    id: root

    property int  columns:    3
    property real cellHeight: 160
    property real gap:        Theme.sp3

    default property alias children: _inner.children

    implicitWidth:  480
    implicitHeight: _inner.implicitHeight

    // Attached property helpers
    property real _colW: (width + gap) / columns - gap

    Item {
        id:     _inner
        width:  parent.width
        height: implicitHeight

        implicitHeight: {
            var maxBottom = 0
            for (var i = 0; i < children.length; i++) {
                var b = children[i].y + children[i].height
                if (b > maxBottom) maxBottom = b
            }
            return maxBottom
        }

        Component.onCompleted: _relayout()
        onChildrenChanged:     _relayout()

        function _relayout(): void {
            var col = 0, row = 0
            var colW = root._colW
            for (var i = 0; i < children.length; i++) {
                var child = children[i]
                var span  = child.hasOwnProperty("_dashColSpan") ? child._dashColSpan : 1
                span = Math.min(span, root.columns)
                if (col + span > root.columns) { col = 0; row++ }
                child.x      = col * (colW + root.gap)
                child.y      = row * (root.cellHeight + root.gap)
                child.width  = span * (colW + root.gap) - root.gap
                child.height = root.cellHeight
                col += span
            }
        }
    }

    onColumnsChanged:    _inner._relayout()
    onWidthChanged:      _inner._relayout()
    onCellHeightChanged: _inner._relayout()
    onGapChanged:        _inner._relayout()

    // Attached property: set colSpan on children
    // Usage: SomeCard { property int _dashColSpan: 2 }
}
