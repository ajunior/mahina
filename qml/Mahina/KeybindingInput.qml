import QtQuick
import Mahina

// Click to record a keyboard shortcut; displays modifier + key combination.
//
// Usage:
//   KeybindingInput {
//       keybinding: "Ctrl+Shift+P"
//       onKeybindingChanged: (kb) => settings.shortcut = kb
//   }
Item {
    id: root

    property string keybinding:  ""
    property bool   recording:   false
    property string placeholder: "Click to record shortcut"

    signal bindingCommitted(string binding)

    implicitWidth:  220
    implicitHeight: 36

    function _keyName(key) {
        if (key >= Qt.Key_A && key <= Qt.Key_Z)
            return String.fromCharCode(key)
        if (key >= Qt.Key_0 && key <= Qt.Key_9)
            return String.fromCharCode(key)
        var map = {
            [Qt.Key_F1]: "F1",   [Qt.Key_F2]: "F2",   [Qt.Key_F3]: "F3",
            [Qt.Key_F4]: "F4",   [Qt.Key_F5]: "F5",   [Qt.Key_F6]: "F6",
            [Qt.Key_F7]: "F7",   [Qt.Key_F8]: "F8",   [Qt.Key_F9]: "F9",
            [Qt.Key_F10]: "F10", [Qt.Key_F11]: "F11", [Qt.Key_F12]: "F12",
            [Qt.Key_Space]: "Space",   [Qt.Key_Return]: "Return",
            [Qt.Key_Tab]: "Tab",       [Qt.Key_Delete]: "Delete",
            [Qt.Key_Home]: "Home",     [Qt.Key_End]: "End",
            [Qt.Key_PageUp]: "PgUp",   [Qt.Key_PageDown]: "PgDn",
            [Qt.Key_Left]: "Left",     [Qt.Key_Right]: "Right",
            [Qt.Key_Up]: "Up",         [Qt.Key_Down]: "Down",
            [Qt.Key_Backspace]: "Backspace", [Qt.Key_Escape]: "Escape",
        }
        return map[key] || ""
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSm
        color:  root.recording
                ? Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.08)
                : Theme.surface
        border.color: root.recording ? Theme.primary : Theme.border
        border.width: root.recording ? 2 : 1
        Behavior on color        { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }

        Row {
            anchors.centerIn: parent
            spacing: Theme.sp2

            Text {
                text:  root.recording ? "⏺" : "⌨"
                color: root.recording ? Theme.primary : Theme.textDisabled
                font.pixelSize: 13
            }

            Text {
                text:  root.keybinding !== ""
                       ? root.keybinding
                       : (root.recording ? "Press keys…" : root.placeholder)
                color: root.recording
                       ? Theme.primary
                       : (root.keybinding !== "" ? Theme.textPrimary : Theme.textDisabled)
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
            }

            Rectangle {
                visible: root.keybinding !== "" && !root.recording
                width: 16; height: 16; radius: 8
                color: _kbClH.hovered ? Theme.panel : "transparent"
                Behavior on color { ColorAnimation { duration: 80 } }
                HoverHandler { id: _kbClH }
                Text { anchors.centerIn: parent; text: "✕"; color: Theme.textDisabled; font.pixelSize: 8 }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: { root.keybinding = ""; root.bindingCommitted("") }
                }
            }
        }

        // Key capture area
        Item {
            id:    _kbCapture
            anchors.fill: parent
            focus: root.recording

            Keys.onPressed: (e) => {
                if (!root.recording) return
                e.accepted = true
                if (e.key === Qt.Key_Escape) { root.recording = false; return }
                if (e.key === Qt.Key_Control || e.key === Qt.Key_Alt ||
                    e.key === Qt.Key_Shift   || e.key === Qt.Key_Meta) return

                var parts = []
                if (e.modifiers & Qt.ControlModifier) parts.push("Ctrl")
                if (e.modifiers & Qt.AltModifier)     parts.push("Alt")
                if (e.modifiers & Qt.ShiftModifier)   parts.push("Shift")
                if (e.modifiers & Qt.MetaModifier)    parts.push("Meta")
                var kn = root._keyName(e.key)
                if (kn !== "") parts.push(kn)
                if (parts.length > 0) {
                    root.keybinding = parts.join("+")
                    root.bindingCommitted(root.keybinding)
                }
                root.recording = false
            }
        }

        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.recording = !root.recording
                if (root.recording) _kbCapture.forceActiveFocus()
            }
        }
    }
}
