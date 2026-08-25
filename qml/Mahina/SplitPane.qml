import QtQuick
import Mahina

// Two panels with a draggable divider.
//
// Usage:
//   SplitPane {
//       firstItem:  FileTree { }
//       secondItem: CodeEditor { }
//   }
//
//   SplitPane {
//       orientation: SplitPane.Orientation.Vertical
//       ratio:       0.6
//       firstItem:   Chart { }
//       secondItem:  DataTable { }
//   }
Item {
    id: root

    enum Orientation { Horizontal, Vertical }

    property int  orientation:    SplitPane.Orientation.Horizontal
    property real ratio:          0.5
    property real minRatio:       0.1
    property real maxRatio:       0.9
    property Item firstItem:      null
    property Item secondItem:     null
    property bool firstVisible:   true
    property bool secondVisible:  true

    readonly property bool _horiz: root.orientation === SplitPane.Orientation.Horizontal
    readonly property real _effectiveRatio: {
        if (!firstVisible)  return 0.0
        if (!secondVisible) return 1.0
        return ratio
    }
    // Animated ratio — follows _effectiveRatio with a slide easing
    property real _animatedRatio: _effectiveRatio
    Behavior on _animatedRatio {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    // When divider is hidden, don't subtract/add its thickness from slot sizes
    readonly property real _ht: (firstVisible && secondVisible) ? _divider.halfThick : 0

    // Reparent items into their containers when assigned
    onFirstItemChanged:  if (firstItem)  firstItem.parent  = _firstSlot
    onSecondItemChanged: if (secondItem) secondItem.parent = _secondSlot

    // First panel
    Item {
        id:      _firstSlot
        visible: root.firstVisible
        x:       0; y: 0
        width:   _horiz ? root._animatedRatio * root.width  - root._ht : root.width
        height:  _horiz ? root.height : root._animatedRatio * root.height - root._ht

        clip: true

        // Stretch first child to fill
        onChildrenChanged: {
            if (children.length > 0) {
                children[0].anchors.fill = children[0].parent
            }
        }
    }

    // Divider: a 1px visible line; the grab zone is ~9px wide but invisible,
    // overlapping both panels so the split looks seamless yet stays easy to
    // catch. The line tints to primary while hovered or dragged.
    Item {
        id:           _divider
        readonly property real lineThick: 1
        readonly property real halfThick: lineThick / 2
        readonly property real grabThick: 9

        visible: root._animatedRatio > 0.0 && root._animatedRatio < 1.0
        x:       _horiz ? root._animatedRatio * root.width - grabThick / 2 : 0
        y:       _horiz ? 0 : root._animatedRatio * root.height - grabThick / 2
        width:  _horiz ? grabThick : root.width
        height: _horiz ? root.height : grabThick
        z:      10

        readonly property bool _active: _divHov.hovered || _drag.pressed

        Rectangle {
            anchors.centerIn: parent
            width:  _horiz ? _divider.lineThick : parent.width
            height: _horiz ? parent.height : _divider.lineThick
            color:  _divider._active ? Theme.primary : Theme.border
            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
        }

        HoverHandler { id: _divHov; cursorShape: _horiz ? Qt.SizeHorCursor : Qt.SizeVerCursor }

        MouseArea {
            id:          _drag
            anchors.fill: parent
            cursorShape: _horiz ? Qt.SizeHorCursor : Qt.SizeVerCursor
            onPositionChanged: (mouse) => {
                if (!pressed) return
                if (root._horiz) {
                    var absX = _divider.x + mouse.x
                    root.ratio = Math.max(root.minRatio, Math.min(root.maxRatio, absX / root.width))
                } else {
                    var absY = _divider.y + mouse.y
                    root.ratio = Math.max(root.minRatio, Math.min(root.maxRatio, absY / root.height))
                }
            }
        }
    }

    // Second panel
    Item {
        id:      _secondSlot
        visible: root.secondVisible
        x:       _horiz ? root._animatedRatio * root.width  + root._ht : 0
        y:       _horiz ? 0 : root._animatedRatio * root.height + root._ht
        width:   _horiz ? root.width  - root._animatedRatio * root.width  - root._ht : root.width
        height:  _horiz ? root.height : root.height - root._animatedRatio * root.height - root._ht

        clip: true

        onChildrenChanged: {
            if (children.length > 0) {
                children[0].anchors.fill = children[0].parent
            }
        }
    }
}
