pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

// Scrollable container with styled scroll bars.
//
// Usage:
//   ScrollArea {
//       width: 300; height: 200
//       Column {
//           Repeater { model: 30; delegate: Text { text: "Row " + index } }
//       }
//   }
//
//   // Horizontal scroll:
//   ScrollArea { width: 400; height: 60; horizontal: true; vertical: false
//       Row { Repeater { model: 20; delegate: Chip { text: "tag " + index } } }
//   }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    default property alias content: _inner.data

    property bool vertical:   true
    property bool horizontal: false
    property bool clip:       true

    // ── Flickable ─────────────────────────────────────────────────────────────
    Flickable {
        id:            _flick
        anchors.fill:  parent
        clip:          root.clip
        contentWidth:  root.horizontal ? _inner.implicitWidth  : width
        contentHeight: root.vertical   ? _inner.implicitHeight : height
        boundsBehavior: Flickable.StopAtBounds

        Item {
            id:              _inner
            width:           root.horizontal ? implicitWidth  : _flick.width
            height:          root.vertical   ? implicitHeight : _flick.height
            implicitWidth:   childrenRect.width
            implicitHeight:  childrenRect.height
        }

        // ── Vertical scrollbar ────────────────────────────────────────────────
        QQC.ScrollBar.vertical: QQC.ScrollBar {
            id:       _vBar
            visible:  root.vertical && _flick.contentHeight > _flick.height
            policy:   QQC.ScrollBar.AsNeeded

            contentItem: Rectangle {
                implicitWidth:  6
                implicitHeight: 40
                radius:         width / 2
                color:          _vBar.pressed  ? Theme.borderStrong
                              : _vBar.hovered  ? Theme.textDisabled
                              : Theme.border
                opacity:        _vBar.active ? 1 : 0

                Behavior on color   { ColorAnimation { duration: Theme.durationFast } }
                Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }
            }

            background: Rectangle {
                implicitWidth: 6
                color:         "transparent"
            }
        }

        // ── Horizontal scrollbar ──────────────────────────────────────────────
        QQC.ScrollBar.horizontal: QQC.ScrollBar {
            id:       _hBar
            visible:  root.horizontal && _flick.contentWidth > _flick.width
            policy:   QQC.ScrollBar.AsNeeded

            contentItem: Rectangle {
                implicitWidth:  40
                implicitHeight: 6
                radius:         height / 2
                color:          _hBar.pressed ? Theme.borderStrong
                              : _hBar.hovered ? Theme.textDisabled
                              : Theme.border
                opacity:        _hBar.active ? 1 : 0

                Behavior on color   { ColorAnimation { duration: Theme.durationFast } }
                Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }
            }

            background: Rectangle {
                implicitHeight: 6
                color:          "transparent"
            }
        }
    }
}
