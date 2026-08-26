pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Phone number input with country code selector and auto-formatting.
//
// Usage:
//   PhoneInput { countryCode: "+1"; onValueChanged: (v) => console.log(v) }
Item {
    id: root

    property string countryCode: "+1"
    property string rawDigits:   ""
    property bool   focused:     false

    signal valueChanged(string full)
    signal editingFinished()

    implicitWidth:  260
    implicitHeight: 40

    // Format US/CA: (###) ###-####
    readonly property string _formatted: {
        var d = rawDigits
        if (d.length === 0) return ""
        if (d.length <= 3) return "(" + d
        if (d.length <= 6) return "(" + d.substring(0,3) + ") " + d.substring(3)
        return "(" + d.substring(0,3) + ") " + d.substring(3,6) + "-" + d.substring(6,10)
    }

    function _addDigit(ch: var): void {
        if (!/\d/.test(ch)) return
        if (rawDigits.length >= 10) return
        rawDigits = rawDigits + ch
        root.valueChanged(root.countryCode + rawDigits)
    }
    function _removeDigit(): void {
        if (rawDigits.length > 0)
            rawDigits = rawDigits.substring(0, rawDigits.length - 1)
    }
    function clear(): void { rawDigits = "" }

    Row {
        anchors.fill: parent
        spacing: 0

        // Country code badge
        Rectangle {
            width:  60; height: parent.height
            color:  Theme.panel
            radius: Theme.radiusMd
            border.color: root.focused ? Theme.primary : Theme.border
            border.width: root.focused ? 2 : 1
            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

            Text {
                anchors.centerIn: parent
                text:           root.countryCode
                color:          Theme.textSecondary
                font.family:    Theme.fontFamilyMono
                font.pixelSize: Theme.textSm
            }
        }

        Rectangle { width: 1; height: parent.height; color: Theme.border }

        // Number field
        Rectangle {
            width:  parent.width - 61
            height: parent.height
            color:  Theme.surface
            radius: Theme.radiusMd
            border.color: root.focused ? Theme.primary : Theme.border
            border.width: root.focused ? 2 : 1
            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

            TextInput {
                id:             _ti
                anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                verticalAlignment: TextInput.AlignVCenter
                text:           root._formatted
                readOnly:       true
                color:          "transparent"

                onActiveFocusChanged: root.focused = activeFocus

                Keys.onPressed: (e) => {
                    if (e.key === Qt.Key_Backspace) { root._removeDigit(); e.accepted = true; return }
                    if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { root.editingFinished(); e.accepted = true; return }
                    if (e.text !== "") { root._addDigit(e.text); e.accepted = true }
                }
            }

            // Visual text overlay
            Item {
                anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }

                Text {
                    visible:        root.rawDigits === "" && !root.focused
                    anchors.verticalCenter: parent.verticalCenter
                    text:           "(___) ___-____"
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textSm
                }
                Text {
                    id:             _display
                    visible:        root.rawDigits !== "" || root.focused
                    anchors.verticalCenter: parent.verticalCenter
                    text:           root._formatted
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textSm
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                onClicked: _ti.forceActiveFocus()
            }
        }
    }
}
