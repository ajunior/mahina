pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Rubber-band selection overlay — drag to draw a selection rectangle.
//
// Usage:
//   SelectionRect {
//       anchors.fill: _canvas
//       onSelectionChanged: (rect) => selectItemsInRect(rect)
//   }
Item {
    id: root

    property bool  active:        true
    property color selectionColor: Theme.primary
    property real  selectionAlpha: 0.15

    signal selectionChanged(var selRect)   // {x, y, width, height} in item coordinates
    signal selectionCommitted(var selRect)

    readonly property rect selectionRect: Qt.rect(
        Math.min(_sx, _ex), Math.min(_sy, _ey),
        Math.abs(_ex - _sx), Math.abs(_ey - _sy))

    property bool _dragging: false
    property real _sx: 0; property real _sy: 0
    property real _ex: 0; property real _ey: 0

    MouseArea {
        anchors.fill: parent
        cursorShape:  root.active ? Qt.CrossCursor : Qt.ArrowCursor
        enabled:      root.active

        onPressed: (m) => {
            root._sx = m.x; root._sy = m.y
            root._ex = m.x; root._ey = m.y
            root._dragging = true
        }
        onPositionChanged: (m) => {
            if (!root._dragging) return
            root._ex = m.x; root._ey = m.y
            root.selectionChanged(root.selectionRect)
        }
        onReleased: {
            root._dragging = false
            root.selectionCommitted(root.selectionRect)
        }
    }

    // Selection rectangle visual
    Rectangle {
        visible: root._dragging && (root.selectionRect.width > 2 || root.selectionRect.height > 2)
        x:      root.selectionRect.x
        y:      root.selectionRect.y
        width:  root.selectionRect.width
        height: root.selectionRect.height
        color:  Qt.rgba(Qt.color(root.selectionColor).r,
                        Qt.color(root.selectionColor).g,
                        Qt.color(root.selectionColor).b,
                        root.selectionAlpha)
        border.color: root.selectionColor
        border.width: 1
        radius: 2
    }
}
