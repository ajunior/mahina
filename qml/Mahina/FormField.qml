pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Wrapper that adds label, hint, and error message to any form control.
//
// Usage:
//   FormField {
//       label: "Email address"
//       hint:  "We'll never share your email."
//       error: hasError ? "Please enter a valid email." : ""
//       required: true
//       TextField { width: parent.width }
//   }
Item {
    id: root

    property string label:    ""
    property string hint:     ""
    property string errorMsg: ""
    property bool   required: false

    default property alias content: _contentArea.data

    implicitWidth:  _col.implicitWidth
    implicitHeight: _col.implicitHeight

    Column {
        id:     _col
        width:  parent.width
        spacing: Theme.sp1

        // Label row
        Row {
            spacing: 3
            visible: root.label !== ""

            Text {
                text:           root.label
                color:          root.errorMsg !== "" ? Theme.error : Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Font.Medium
            }
            Text {
                visible:        root.required
                text:           "*"
                color:          Theme.error
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
            }
        }

        // Slotted control
        Item {
            id:     _contentArea
            width:  _col.width
            implicitHeight: {
                var h = 0
                for (var i = 0; i < _contentArea.children.length; i++) {
                    var ch = _contentArea.children[i]
                    h = Math.max(h, ch.implicitHeight || ch.height || 0)
                }
                return h || 36
            }
        }

        // Error message
        Row {
            spacing: 4
            visible: root.errorMsg !== ""
            Text {
                text:           "⚠"
                color:          Theme.error
                font.pixelSize: Theme.textXs
            }
            Text {
                text:           root.errorMsg
                color:          Theme.error
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
                wrapMode:       Text.Wrap
                width:          _col.width - 16
            }
        }

        // Hint
        Text {
            visible:        root.errorMsg === "" && root.hint !== ""
            text:           root.hint
            color:          Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            wrapMode:       Text.Wrap
            width:          _col.width
        }
    }
}
