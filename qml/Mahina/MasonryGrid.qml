pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Masonry (Pinterest-style) column grid layout.
// Items are distributed across columns by index (round-robin), not by measured height.
// Use equal-height items or a fixed-height delegate for pixel-perfect results.
//
// Usage:
//   MasonryGrid {
//       columns: 3
//       spacing: 12
//       model:   myModel
//       delegate: Card {
//           width:  parent.width
//           height: modelData.height   // vary per item
//           ...
//       }
//   }
Item {
    id: root

    property int columns:  3
    property real spacing: Theme.sp3
    property alias model:    _rep.model
    property alias delegate: _rep.delegate

    implicitWidth:  400
    implicitHeight: _maxColH()

    function _maxColH() {
        var m = 0
        for (var c = 0; c < _colItems.length; c++)
            if (_colItems[c]) m = Math.max(m, _colItems[c].height)
        return m
    }

    readonly property real _colW: (width - (columns - 1) * spacing) / Math.max(1, columns)

    // Column containers
    Repeater {
        id:    _colRep
        model: root.columns
        delegate: Column {
            required property int index
            x:       index * (root._colW + root.spacing)
            y:       0
            width:   root._colW
            spacing: root.spacing
        }
    }

    // Items placed into columns
    Repeater {
        id: _rep
        onItemAdded: (idx, item) => {
            var col = idx % root.columns
            var colContainer = _colRep.itemAt(col)
            if (colContainer) item.parent = colContainer
        }
        onItemRemoved: (idx, item) => {
            item.parent = null
        }
    }

    // Recompute height whenever column children change
    property var _colItems: {
        var arr = []
        for (var i = 0; i < root.columns; i++) arr.push(_colRep.itemAt(i))
        return arr
    }

    onWidthChanged: {
        for (var i = 0; i < root.columns; i++) {
            var c = _colRep.itemAt(i)
            if (c) c.width = root._colW
        }
    }
}
