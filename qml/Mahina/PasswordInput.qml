pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Password field with show/hide toggle and optional strength meter.
//
// Usage:
//   PasswordInput { label: "Password"; placeholder: "Min 8 characters" }
//
//   PasswordInput {
//       id: _pass
//       showStrength: true
//       onValueChanged: validateForm()
//   }
//
//   PasswordInput { showStrength: false; disabled: true; value: "•••••••••" }
Item {
    id: root

    property string value:        ""
    property bool   showStrength: true
    property string label:        ""
    property string placeholder:  "Password"
    property string helper:       ""
    property string errorText:    ""
    property bool   disabled:     false

    implicitWidth:  300
    implicitHeight: _col.implicitHeight

    readonly property bool _hasError: root.errorText !== ""
    property bool _focused: false
    property bool _showPwd: false

    // 0=empty 1=weak 2=fair 3=strong 4=very-strong
    readonly property int strength: {
        var pwd = root.value
        if (pwd.length === 0) return 0
        var s = 0
        if (pwd.length >= 8) s++
        if (/[A-Z]/.test(pwd)) s++
        if (/[0-9]/.test(pwd)) s++
        if (/[^A-Za-z0-9]/.test(pwd)) s++
        return s
    }

    readonly property color _strengthColor: {
        switch (root.strength) {
            case 1:  return Theme.error
            case 2:  return Theme.warning
            case 3:  return Theme.success
            case 4:  return Theme.success
            default: return Theme.border
        }
    }
    readonly property string _strengthLabel: {
        switch (root.strength) {
            case 1:  return "Weak"
            case 2:  return "Fair"
            case 3:  return "Strong"
            case 4:  return "Very strong"
            default: return ""
        }
    }

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.sp1

        Text {
            visible:        root.label !== ""
            text:           root.label
            color:          Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            font.weight:    Theme.weightMedium
        }

        Rectangle {
            Layout.fillWidth: true
            height:           40
            color:            root.disabled ? Theme.panel : Theme.surface
            radius:           Theme.radiusMd
            border.color:     root._hasError ? Theme.error
                            : root._focused   ? Theme.primary
                            : Theme.border
            border.width:     root._focused || root._hasError ? 2 : 1
            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

            RowLayout {
                anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp2 }
                spacing: 0

                TextInput {
                    id:             _input
                    text:           root.value
                    echoMode:       root._showPwd ? TextInput.Normal : TextInput.Password
                    color:          root.disabled ? Theme.textDisabled : Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    enabled:        !root.disabled
                    Layout.fillWidth: true
                    onTextChanged: root.value = text
                    onActiveFocusChanged: root._focused = activeFocus
                }

                Rectangle {
                    width: 32; height: 32; radius: Theme.radiusSm
                    color: _eyeH.containsMouse ? Theme.panel : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _eyeH }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root._showPwd = !root._showPwd
                    }
                    Icon { anchors.centerIn: parent; name: root._showPwd ? Icons.eyeSlash : Icons.eye; size: 16; color: Theme.textSecondary }
                }
            }

            // Placeholder
            Text {
                visible:        _input.text === "" && !_input.activeFocus
                anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                text:           root.placeholder
                color:          Theme.textDisabled
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
            }
        }

        // Strength bar
        ColumnLayout {
            visible:          root.showStrength && root.value.length > 0 && !root._hasError
            Layout.fillWidth: true
            spacing:          Theme.sp1

            Row {
                spacing: Theme.sp1
                Repeater {
                    model: 4
                    Rectangle {
                        id: _bar
                        required property int index
                        width:  (root.implicitWidth - Theme.sp1 * 3) / 4
                        height: 3; radius: 2
                        color:  _bar.index < root.strength ? root._strengthColor : Theme.border
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    }
                }
            }

            Text {
                text:           root._strengthLabel
                color:          root._strengthColor
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
                font.weight:    Theme.weightMedium
                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            }
        }

        RowLayout {
            Text {
                visible:        root.helper !== "" && !root._hasError && !(root.showStrength && root.value.length > 0)
                text:           root.helper
                color:          Theme.textDisabled
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
            }
            Text {
                visible:        root._hasError
                text:           root.errorText
                color:          Theme.error
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
            }
        }
    }
}
