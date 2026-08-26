pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Auto-formatted credit card number input. Detects brand from prefix.
//
// Usage:
//   CreditCardInput {
//       onCardNumberEntered: (num, brand) => processCard(num, brand)
//   }
Item {
    id: root

    property string cardNumber: ""   // formatted display value
    property string rawNumber:  ""   // digits only
    property string brand:      ""   // "visa" | "mastercard" | "amex" | "discover" | ""

    signal cardNumberEntered(string number, string brand)

    implicitWidth:  320
    implicitHeight: 48

    function _detectBrand(digits) {
        if (digits.length === 0) return ""
        var d = digits
        if (d[0] === "4") return "visa"
        if (d[0] === "5" && d.length > 1 && d[1] >= "1" && d[1] <= "5") return "mastercard"
        if (d.length > 1 && d[0] === "3" && (d[1] === "4" || d[1] === "7")) return "amex"
        if (d.length > 3 && d.slice(0,4) === "6011") return "discover"
        return ""
    }

    function _formatNumber(digits) {
        // Amex: 4-6-5, others: 4-4-4-4
        if (root.brand === "amex") {
            var p1 = digits.slice(0, 4)
            var p2 = digits.slice(4, 10)
            var p3 = digits.slice(10, 15)
            return [p1, p2, p3].filter(function(p) { return p.length > 0 }).join(" ")
        } else {
            var parts = []
            for (var i = 0; i < digits.length; i += 4) parts.push(digits.slice(i, i+4))
            return parts.join(" ")
        }
    }

    Rectangle {
        anchors.fill: parent
        radius:       Theme.radiusMd
        color:        Theme.surface
        border.color: _input.activeFocus ? Theme.primary : Theme.border
        border.width: _input.activeFocus ? 2 : 1

        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

        Row {
            anchors { fill: parent; leftMargin: Theme.sp4; rightMargin: Theme.sp3 }
            spacing: Theme.sp3

            // Brand badge
            Rectangle {
                width:  36; height: 24
                anchors.verticalCenter: parent.verticalCenter
                radius: 4
                color:  Theme.panel
                border.color: Theme.border; border.width: 1
                visible: root.brand !== ""

                Text {
                    anchors.centerIn: parent
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    font.weight:    Theme.weightBold
                    color:          Theme.textSecondary
                    text: {
                        switch (root.brand) {
                        case "visa":       return "VISA"
                        case "mastercard": return "MC"
                        case "amex":       return "AMEX"
                        case "discover":   return "DISC"
                        default:           return ""
                        }
                    }
                }
            }

            Rectangle {
                width:  36; height: 24
                anchors.verticalCenter: parent.verticalCenter
                radius: 4
                color:  Theme.panel
                border.color: Theme.border; border.width: 1
                visible: root.brand === ""

                Text {
                    anchors.centerIn: parent
                    text:           "💳"
                    font.pixelSize: 14
                }
            }

            TextInput {
                id:             _input
                anchors.verticalCenter: parent.verticalCenter
                width:          parent.width - 48 - Theme.sp3
                color:          Theme.textPrimary
                font.family:    Theme.fontFamilyMono
                font.pixelSize: Theme.textBase
                text:           root.cardNumber
                inputMethodHints: Qt.ImhDigitsOnly

                onTextEdited: {
                    // Strip non-digits and spaces, then re-format
                    var raw = text.replace(/\D/g, "")
                    var maxLen = root.brand === "amex" ? 15 : 16
                    if (raw.length > maxLen) raw = raw.slice(0, maxLen)
                    root.rawNumber  = raw
                    root.brand      = root._detectBrand(raw)
                    root.cardNumber = root._formatNumber(raw)
                    // Prevent feedback loop: only set if different
                    if (text !== root.cardNumber) {
                        var p = cursorPosition
                        text = root.cardNumber
                        cursorPosition = Math.min(p, root.cardNumber.length)
                    }
                    if (raw.length >= (root.brand === "amex" ? 15 : 16)) {
                        root.cardNumberEntered(raw, root.brand)
                    }
                }
            }
        }

        // Placeholder
        Text {
            visible:        _input.text.length === 0 && !_input.activeFocus
            text:           "0000 0000 0000 0000"
            color:          Theme.textDisabled
            font.family:    Theme.fontFamilyMono
            font.pixelSize: Theme.textBase
            anchors {
                left:           parent.left
                leftMargin:     36 + Theme.sp3 + Theme.sp4 + Theme.sp3
                verticalCenter: parent.verticalCenter
            }
        }
    }
}
