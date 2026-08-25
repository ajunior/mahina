import QtQuick
import QtQuick.Controls.Basic as QQC
import Mahina

// Wraps any item and shows a styled tooltip on hover.
//
// Usage:
//   Tooltip {
//       text: "Open settings"
//       Button { text: "Settings" }
//   }
//
//   // Attach to an existing item via the `target` property:
//   Button { id: saveBtn; text: "Save" }
//   Tooltip { text: "Save the document (Ctrl+S)"; target: saveBtn }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    default property alias content: _slot.data
    property string text:  ""
    property int    delay: 500

    // Optional: attach tooltip to an external item instead of wrapping
    property Item   target: null

    // ── Size to wrapped content ───────────────────────────────────────────────
    implicitWidth:  _slot.childrenRect.width
    implicitHeight: _slot.childrenRect.height

    Item {
        id:           _slot
        anchors.fill: parent
    }

    // ── Hover detection ───────────────────────────────────────────────────────
    // Covers either the wrapper or the external `for` target
    HoverHandler {
        id:      _selfHover
        target:  root.target === null ? root : null
        enabled: root.target === null
    }

    HoverHandler {
        id:      _targetHover
        target:  root.target
        enabled: root.target !== null
    }

    readonly property bool _hovered: root.target !== null ? _targetHover.hovered : _selfHover.hovered

    // ── Tooltip popup ─────────────────────────────────────────────────────────
    QQC.ToolTip {
        id:      _tip
        visible: root._hovered && root.text !== ""
        text:    root.text
        delay:   root.delay
        timeout: 5000

        // ── Content ───────────────────────────────────────────────────────────
        contentItem: Text {
            text:           _tip.text
            color:          "#FFFFFF"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            wrapMode:       Text.WordWrap
            maximumLineCount: 4
        }

        // ── Background ────────────────────────────────────────────────────────
        // Dark pill regardless of light/dark mode — high contrast, unmistakable
        background: Rectangle {
            color:  "#1E2030"
            radius: Theme.radiusSm

            // Subtle inner border for depth
            Rectangle {
                anchors.fill:    parent
                anchors.margins: 1
                radius:          parent.radius - 1
                color:           "transparent"
                border.color:    "#FFFFFF"
                border.width:    1
                opacity:         0.08
            }
        }

        // Compact padding
        topPadding:    Theme.sp1 + 2
        bottomPadding: Theme.sp1 + 2
        leftPadding:   Theme.sp2 + 2
        rightPadding:  Theme.sp2 + 2
    }
}
