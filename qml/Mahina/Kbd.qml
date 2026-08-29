pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Keyboard shortcut display — renders each key as a physical-looking pill.
//
// Usage:
//   Kbd { shortcut: "Ctrl+K" }          // → [Ctrl] [K]
//   Kbd { shortcut: "⌘+Shift+P" }       // → [⌘] [Shift] [P]
//   Kbd { keys: ["⌘", "K"] }            // explicit keys array
//   Kbd { keys: ["Esc"] }               // single key
//
// Note: pass "⌘K" as keys: ["⌘","K"] or shortcut: "⌘+K" — splitting on "+"
//       means "⌘K" (no plus) is treated as a single key label.
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string shortcut: ""
    property var    keys:     []

    // Keys are named the way the current platform names them — "Ctrl" prints
    // as ⌘ on macOS, where that is the key Qt actually binds. Set false to
    // print the labels exactly as given.
    property bool   nativeKeys: true

    // Derive key list: explicit array wins; fallback to splitting shortcut by "+"
    readonly property var _keys: {
        if (root.keys.length > 0) return root.keys
        if (root.shortcut === "")  return []
        return root.shortcut.split("+").map(k => k.trim()).filter(k => k !== "")
    }

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  _row.implicitWidth
    implicitHeight: _row.implicitHeight

    // ── Keys ─────────────────────────────────────────────────────────────────
    RowLayout {
        id:      _row
        spacing: Theme.sp1

        Repeater {
            model: root._keys

            delegate: Item {
                id: _rq1
                required property var modelData

                implicitWidth:  _kText.implicitWidth + Theme.sp2 * 2
                implicitHeight: 20

                // Depth shadow (thin strip below the key face)
                Rectangle {
                    anchors.fill: parent
                    radius:       Theme.radiusXs
                    color:        Theme.borderStrong
                }

                // Key face
                Rectangle {
                    anchors {
                        top:    parent.top
                        left:   parent.left
                        right:  parent.right
                        bottom: parent.bottom
                        bottomMargin: 2
                    }
                    radius:       Theme.radiusXs
                    color:        Theme.panel
                    border.color: Theme.border
                    border.width: 1

                    Text {
                        id:               _kText
                        anchors.centerIn: parent
                        text:             root.nativeKeys ? KeyLabels.key(_rq1.modelData)
                                                            : _rq1.modelData
                        color:            Theme.textSecondary
                        font.family:      Theme.fontFamilyMono
                        font.pixelSize:   Theme.textXs
                        font.weight:      Theme.weightMedium
                    }
                }
            }
        }
    }
}
