import QtQuick
import Mahina

// Keyboard shortcut display pill — shows one or more key labels.
//
// Usage:
//   ShortcutHint { keys: ["Ctrl", "K"] }
//   ShortcutHint { keys: ["⌘", "Shift", "P"]; size: "sm" }
//   Row { spacing: 4; Text { text: "Open palette" }; ShortcutHint { keys: ["Ctrl","K"] } }
Item {
    id: root

    property var    keys: []
    property string size: "md"   // "sm" | "md"

    readonly property real _h:   root.size === "sm" ? 18 : 22
    readonly property real _fsz: root.size === "sm" ? 9  : Theme.textXs

    implicitWidth:  _row.implicitWidth
    implicitHeight: _h

    Row {
        id:      _row
        spacing: 2

        Repeater {
            model: root.keys
            delegate: Rectangle {
                id: _rq1
                required property string modelData
                height: root._h
                width:  _kt.implicitWidth + 8
                radius: Theme.radiusXs
                color:  Theme.panel
                border.color: Theme.borderStrong; border.width: 1

                // Bottom shadow line
                Rectangle {
                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                    height: 2; radius: Theme.radiusXs
                    color:  Theme.borderStrong
                }

                Text {
                    id:             _kt
                    anchors.centerIn: parent
                    text:           _rq1.modelData
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: root._fsz
                    font.weight:    Theme.weightMedium
                }
            }
        }
    }
}
