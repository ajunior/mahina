pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Wraps any content with drag-to-resize handles on specified edges.
//
// Usage:
//   Resizable {
//       width: 320; height: 200
//       edges: ["e", "s", "se"]      // enable right, bottom, and corner handle
//       minWidth: 120; maxWidth: 600
//       minHeight: 80;  maxHeight: 400
//
//       Rectangle { anchors.fill: parent; color: Theme.surface; ... }
//   }
//
// edges: any combination of "n" | "s" | "e" | "w" | "ne" | "nw" | "se" | "sw"
Item {
    id: root

    default property alias content: _inner.data

    property var  edges:     ["e", "s", "se"]
    property real minWidth:  80
    property real maxWidth:  9999
    property real minHeight: 40
    property real maxHeight: 9999
    property real handleSize: 6
    property bool showHandles: true

    signal resized(real w, real h)

    Item {
        id:           _inner
        anchors.fill: parent
    }

    // ── Helper: clamp ─────────────────────────────────────────────────────────
    function _cw(w) { return Math.max(root.minWidth,  Math.min(root.maxWidth,  w)) }
    function _ch(h) { return Math.max(root.minHeight, Math.min(root.maxHeight, h)) }

    // ── Edge handles ──────────────────────────────────────────────────────────

    // East
    Item {
        id:      _eHandle
        visible: root.edges.indexOf("e") !== -1 || root.edges.indexOf("ne") !== -1 || root.edges.indexOf("se") !== -1
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        width:   root.handleSize

        MouseArea {
            id:            _eMA
            anchors.fill:  parent
            cursorShape:   Qt.SizeHorCursor
            hoverEnabled:  true
            property real _startX: 0
            property real _startW: 0
            onPressed: (m) => { _startX = mapToGlobal(m.x, m.y).x; _startW = root.width }
            onPositionChanged: (m) => {
                if (!pressed) return
                var dx = mapToGlobal(m.x, m.y).x - _startX
                root.width = _cw(_startW + dx)
                root.resized(root.width, root.height)
            }
        }

        Rectangle {
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
            width:   2; color: Theme.borderStrong; opacity: _eMA.containsMouse ? 0.7 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }
        }
    }

    // South
    Item {
        id:      _sHandle
        visible: root.edges.indexOf("s") !== -1 || root.edges.indexOf("se") !== -1 || root.edges.indexOf("sw") !== -1
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height:  root.handleSize

        MouseArea {
            id:            _sMA
            anchors.fill:  parent
            cursorShape:   Qt.SizeVerCursor
            hoverEnabled:  true
            property real _startY: 0
            property real _startH: 0
            onPressed: (m) => { _startY = mapToGlobal(m.x, m.y).y; _startH = root.height }
            onPositionChanged: (m) => {
                if (!pressed) return
                var dy = mapToGlobal(m.x, m.y).y - _startY
                root.height = _ch(_startH + dy)
                root.resized(root.width, root.height)
            }
        }

        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 2; color: Theme.borderStrong; opacity: _sMA.containsMouse ? 0.7 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }
        }
    }

    // North
    Item {
        id:      _nHandle
        visible: root.edges.indexOf("n") !== -1 || root.edges.indexOf("ne") !== -1 || root.edges.indexOf("nw") !== -1
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height:  root.handleSize

        MouseArea {
            anchors.fill:  parent
            cursorShape:   Qt.SizeVerCursor
            property real _startY:  0
            property real _startH:  0
            property real _startYp: 0
            onPressed: (m) => {
                _startY  = mapToGlobal(m.x, m.y).y
                _startH  = root.height
                _startYp = root.y
            }
            onPositionChanged: (m) => {
                if (!pressed) return
                var dy = mapToGlobal(m.x, m.y).y - _startY
                var nh = _ch(_startH - dy)
                root.y      = _startYp + (_startH - nh)
                root.height = nh
                root.resized(root.width, root.height)
            }
        }
    }

    // West
    Item {
        id:      _wHandle
        visible: root.edges.indexOf("w") !== -1 || root.edges.indexOf("nw") !== -1 || root.edges.indexOf("sw") !== -1
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width:   root.handleSize

        MouseArea {
            anchors.fill:  parent
            cursorShape:   Qt.SizeHorCursor
            property real _startX:  0
            property real _startW:  0
            property real _startXp: 0
            onPressed: (m) => {
                _startX  = mapToGlobal(m.x, m.y).x
                _startW  = root.width
                _startXp = root.x
            }
            onPositionChanged: (m) => {
                if (!pressed) return
                var dx = mapToGlobal(m.x, m.y).x - _startX
                var nw = _cw(_startW - dx)
                root.x     = _startXp + (_startW - nw)
                root.width = nw
                root.resized(root.width, root.height)
            }
        }
    }

    // SE corner
    Item {
        visible: root.edges.indexOf("se") !== -1
        anchors { right: parent.right; bottom: parent.bottom }
        width: root.handleSize + 4; height: root.handleSize + 4

        Rectangle {
            anchors { right: parent.right; bottom: parent.bottom }
            width: 8; height: 8; radius: 2; color: Theme.borderStrong
        }

        MouseArea {
            anchors.fill: parent; cursorShape: Qt.SizeFDiagCursor
            property real _sx: 0; property real _sy: 0
            property real _sw: 0; property real _sh: 0
            onPressed: (m) => {
                _sx = mapToGlobal(m.x, m.y).x; _sy = mapToGlobal(m.x, m.y).y
                _sw = root.width; _sh = root.height
            }
            onPositionChanged: (m) => {
                if (!pressed) return
                var g = mapToGlobal(m.x, m.y)
                root.width  = _cw(_sw + g.x - _sx)
                root.height = _ch(_sh + g.y - _sy)
                root.resized(root.width, root.height)
            }
        }
    }

    // SW corner
    Item {
        visible: root.edges.indexOf("sw") !== -1
        anchors { left: parent.left; bottom: parent.bottom }
        width: root.handleSize + 4; height: root.handleSize + 4

        MouseArea {
            anchors.fill: parent; cursorShape: Qt.SizeBDiagCursor
            property real _sx: 0; property real _sy: 0
            property real _sw: 0; property real _sh: 0; property real _sxp: 0
            onPressed: (m) => {
                _sx = mapToGlobal(m.x, m.y).x; _sy = mapToGlobal(m.x, m.y).y
                _sw = root.width; _sh = root.height; _sxp = root.x
            }
            onPositionChanged: (m) => {
                if (!pressed) return
                var g  = mapToGlobal(m.x, m.y)
                var nw = _cw(_sw - (g.x - _sx))
                root.x      = _sxp + (_sw - nw)
                root.width  = nw
                root.height = _ch(_sh + g.y - _sy)
                root.resized(root.width, root.height)
            }
        }
    }

    // NE corner
    Item {
        visible: root.edges.indexOf("ne") !== -1
        anchors { right: parent.right; top: parent.top }
        width: root.handleSize + 4; height: root.handleSize + 4

        MouseArea {
            anchors.fill: parent; cursorShape: Qt.SizeBDiagCursor
            property real _sx: 0; property real _sy: 0
            property real _sw: 0; property real _sh: 0; property real _syp: 0
            onPressed: (m) => {
                _sx = mapToGlobal(m.x, m.y).x; _sy = mapToGlobal(m.x, m.y).y
                _sw = root.width; _sh = root.height; _syp = root.y
            }
            onPositionChanged: (m) => {
                if (!pressed) return
                var g  = mapToGlobal(m.x, m.y)
                var nh = _ch(_sh - (g.y - _sy))
                root.width  = _cw(_sw + g.x - _sx)
                root.y      = _syp + (_sh - nh)
                root.height = nh
                root.resized(root.width, root.height)
            }
        }
    }

    // NW corner
    Item {
        visible: root.edges.indexOf("nw") !== -1
        anchors { left: parent.left; top: parent.top }
        width: root.handleSize + 4; height: root.handleSize + 4

        MouseArea {
            anchors.fill: parent; cursorShape: Qt.SizeFDiagCursor
            property real _sx: 0; property real _sy: 0
            property real _sw: 0; property real _sh: 0
            property real _sxp: 0; property real _syp: 0
            onPressed: (m) => {
                _sx = mapToGlobal(m.x, m.y).x; _sy = mapToGlobal(m.x, m.y).y
                _sw = root.width; _sh = root.height; _sxp = root.x; _syp = root.y
            }
            onPositionChanged: (m) => {
                if (!pressed) return
                var g  = mapToGlobal(m.x, m.y)
                var nw = _cw(_sw - (g.x - _sx))
                var nh = _ch(_sh - (g.y - _sy))
                root.x      = _sxp + (_sw - nw)
                root.y      = _syp + (_sh - nh)
                root.width  = nw
                root.height = nh
                root.resized(root.width, root.height)
            }
        }
    }
}
