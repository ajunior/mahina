import QtQuick
import Mahina

// Decimal input formatted with currency symbol and thousands separator.
//
// Usage:
//   CurrencyInput { symbol: "$"; value: 1234.56 }
//   CurrencyInput { symbol: "€"; decimals: 2; onValueChanged: (v) => model.price = v }
Item {
    id: root

    property string symbol:    "$"
    property real   value:     0
    property int    decimals:  2
    property real   min:       0
    property real   max:       999999999
    property bool   focused:   false

    signal editingFinished()

    implicitWidth:  160
    implicitHeight: 40

    // Raw string being typed
    property string _raw: ""
    property bool   _editing: false

    // Format a number for display
    function _fmt(n) {
        var fixed  = Math.abs(n).toFixed(root.decimals)
        var parts  = fixed.split(".")
        parts[0]   = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        return root.symbol + (n < 0 ? "-" : "") + parts.join(".")
    }

    function _parseRaw(s) {
        var cleaned = s.replace(/[^0-9.-]/g, "")
        var n = parseFloat(cleaned)
        return isNaN(n) ? 0 : Math.max(root.min, Math.min(root.max, n))
    }

    Rectangle {
        anchors.fill:  parent
        radius:        Theme.radiusMd
        color:         Theme.surface
        border.color:  root.focused ? Theme.primary : Theme.border
        border.width:  root.focused ? 2 : 1
        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

        Row {
            anchors { left: parent.left; right: parent.right;
                      leftMargin: Theme.sp3; rightMargin: Theme.sp3;
                      verticalCenter: parent.verticalCenter }

            TextInput {
                id:             _ti
                width:          parent.width
                text:           root._editing ? root._raw : root._fmt(root.value)
                color:          Theme.textPrimary
                font.family:    Theme.fontFamilyMono
                font.pixelSize: Theme.textSm
                horizontalAlignment: Text.AlignRight
                selectByMouse:  true
                clip:           true

                onActiveFocusChanged: {
                    root.focused = activeFocus
                    if (activeFocus) {
                        root._editing = true
                        root._raw     = root.value.toFixed(root.decimals)
                        _ti.text      = root._raw
                        _ti.selectAll()
                    } else {
                        root._editing = false
                        var n = root._parseRaw(root._raw)
                        root.value = n
                        root.editingFinished()
                    }
                }

                onTextChanged: { if (root._editing) root._raw = text }

                Keys.onReturnPressed: { root._editing = false; focus = false; root.editingFinished() }
                Keys.onEscapePressed: { root._editing = false; text = root._fmt(root.value); focus = false }
            }
        }
    }
}
