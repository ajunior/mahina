pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Text input with a format mask. # = digit, A = letter, * = any char.
// Fixed characters in the mask (like parentheses, dashes) are auto-inserted.
//
// Usage:
//   MaskInput { mask: "(###) ###-####"; placeholder: "Phone number" }
//   MaskInput { mask: "##/##/####";     placeholder: "MM/DD/YYYY"   }
//   MaskInput { mask: "AAA-####";       placeholder: "Plate number"  }
//
// Read rawValue for digits only; text for the formatted string.
Item {
    id: root

    property string mask:        ""
    property string placeholder: ""
    property string rawValue:    ""   // only the user-typed chars (no fixed mask chars)
    property bool   focused:     false

    signal editingFinished()
    signal accepted()

    implicitWidth:  200
    implicitHeight: 40

    // Compute display text from rawValue + mask
    readonly property string _display: {
        var m   = root.mask
        var raw = root.rawValue
        var out = ""
        var ri  = 0
        for (var i = 0; i < m.length; i++) {
            var mc = m[i]
            if (mc === "#" || mc === "A" || mc === "*") {
                if (ri < raw.length) out += raw[ri++]
                else break
            } else {
                if (ri < raw.length) out += mc
                else if (ri === 0 && out.length === 0) {} // don't prefix before first typed char
                else break
            }
        }
        return out
    }

    // Mask placeholder text (shows mask pattern with blanks)
    readonly property string _maskHint: {
        var m = root.mask, out = ""
        for (var i = 0; i < m.length; i++) {
            var mc = m[i]
            out += (mc === "#" || mc === "A" || mc === "*") ? "_" : mc
        }
        return out
    }

    function _addChar(ch: var): void {
        var m    = root.mask
        var raw  = root.rawValue
        var pos  = raw.length
        // Find the mask slot for the next raw char
        var slot = 0
        for (var i = 0; i < m.length; i++) {
            if (m[i] === "#" || m[i] === "A" || m[i] === "*") {
                if (slot === pos) {
                    var valid = (m[i] === "#" && /\d/.test(ch)) ||
                                (m[i] === "A" && /[A-Za-z]/.test(ch)) ||
                                (m[i] === "*")
                    if (valid) root.rawValue = raw + ch
                    return
                }
                slot++
            }
        }
    }

    function _removeChar(): void {
        if (root.rawValue.length > 0)
            root.rawValue = root.rawValue.substring(0, root.rawValue.length - 1)
    }

    function clear(): void { root.rawValue = "" }

    Rectangle {
        anchors.fill:  parent
        radius:        Theme.radiusMd
        color:         Theme.surface
        border.color:  root.focused ? Theme.primary : Theme.border
        border.width:  root.focused ? 2 : 1
        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

        // Hidden TextInput to capture keyboard input
        TextInput {
            id:             _input
            anchors.fill:   parent
            anchors.leftMargin:  Theme.sp3
            anchors.rightMargin: Theme.sp3
            color:          "transparent"   // visual is separate Text
            cursorVisible:  false

            onActiveFocusChanged: root.focused = activeFocus

            Keys.onPressed: (e) => {
                if (e.key === Qt.Key_Backspace) { root._removeChar(); e.accepted = true; return }
                if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { root.accepted(); e.accepted = true; return }
                if (e.text !== "") { root._addChar(e.text); e.accepted = true }
            }

            MouseArea { anchors.fill: parent; onClicked: _input.forceActiveFocus() }
        }

        // Display
        Item {
            anchors { left: parent.left; right: parent.right; leftMargin: Theme.sp3; rightMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
            height: _dispText.implicitHeight

            // Placeholder
            Text {
                visible:        root.rawValue === "" && !root.focused
                text:           root.placeholder
                color:          Theme.textDisabled
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
            }

            // Mask hint (faded background)
            Text {
                visible:        root.focused || root.rawValue !== ""
                text:           root._maskHint
                color:          Theme.textDisabled
                font.family:    Theme.fontFamilyMono
                font.pixelSize: Theme.textSm
            }

            // Typed value
            Text {
                id:             _dispText
                visible:        root.rawValue !== "" || root.focused
                text:           root._display
                color:          Theme.textPrimary
                font.family:    Theme.fontFamilyMono
                font.pixelSize: Theme.textSm
            }

            // Cursor
            Rectangle {
                visible:       root.focused && _cursor.running
                x:             _dispText.implicitWidth
                width:         1; height: _dispText.implicitHeight
                color:         Theme.primary
                property bool _on: true

                SequentialAnimation {
                    id:     _cursor
                    running: root.focused
                    loops:   Animation.Infinite
                    PropertyAction  { target: parent; property: "_on"; value: true  }
                    PauseAnimation  { duration: 530 }
                    PropertyAction  { target: parent; property: "_on"; value: false }
                    PauseAnimation  { duration: 530 }
                }

                opacity: _on ? 1 : 0
            }
        }

        MouseArea {
            anchors.fill: parent; cursorShape: Qt.IBeamCursor
            onClicked: _input.forceActiveFocus()
        }
    }
}
