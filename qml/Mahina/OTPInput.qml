pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Row of single-digit boxes for verification codes and PINs.
//
// Usage:
//   OTPInput { length: 6; onCompleted: (code) => verify(code) }
//   OTPInput { length: 4; masked: true; label: "PIN" }
//   OTPInput { length: 6; errorText: "Invalid code" }
Item {
    id: root

    property int    length:    6
    property string value:     ""
    property bool   masked:    false
    property string label:     ""
    property string helper:    ""
    property string errorText: ""
    property bool   disabled:  false

    signal completed(string value)

    implicitWidth:  length * (cellSize + cellSpacing) - cellSpacing
    implicitHeight: _col.implicitHeight

    property real cellSize:    44
    property real cellSpacing: Theme.sp2

    readonly property bool _hasError: root.errorText !== ""
    property bool _focused: false

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

        // Hidden real input — captures all keystrokes
        TextInput {
            id:            _input
            visible:       false
            maximumLength: root.length
            inputMethodHints: Qt.ImhDigitsOnly
            enabled:       !root.disabled

            onTextChanged: {
                root.value = text
                if (text.length === root.length)
                    root.completed(text)
            }

            onActiveFocusChanged: root._focused = activeFocus
        }

        // Visible digit cells
        Row {
            spacing: root.cellSpacing
            Repeater {
                model: root.length
                delegate: Rectangle {
                    required property int index

                    readonly property string _char: {
                        var ch = index < root.value.length ? root.value[index] : ""
                        return root.masked && ch !== "" ? "•" : ch
                    }
                    readonly property bool _active: _input.activeFocus && index === root.value.length

                    width:        root.cellSize; height: root.cellSize
                    radius:       Theme.radiusMd
                    color:        root.disabled ? Theme.panel : Theme.surface
                    border.color: root._hasError  ? Theme.error
                                : _active          ? Theme.primary
                                : root._focused && index < root.value.length ? Theme.borderStrong
                                : Theme.border
                    border.width: _active || root._hasError ? 2 : 1
                    Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

                    Text {
                        anchors.centerIn: parent
                        text:           parent._char
                        color:          Theme.textPrimary
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textLg
                        font.weight:    Theme.weightSemibold
                    }

                    // Cursor blink in active cell
                    Rectangle {
                        visible:  parent._active && _cursor.running
                        anchors.centerIn: parent
                        width:    2; height: root.cellSize * 0.45
                        color:    Theme.primary
                        property bool running: true
                        SequentialAnimation {
                            running:  root._focused && parent.visible
                            loops:    Animation.Infinite
                            PropertyAnimation { target: parent; property: "opacity"; to: 0; duration: 500 }
                            PropertyAnimation { target: parent; property: "opacity"; to: 1; duration: 500 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked:    _input.forceActiveFocus()
                    }
                }
            }
        }

        Row {
            Text {
                visible:        root._hasError
                text:           root.errorText
                color:          Theme.error
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
            }
            Text {
                visible:        root.helper !== "" && !root._hasError
                text:           root.helper
                color:          Theme.textDisabled
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
            }
        }
    }

    // Tap anywhere on the component to focus the hidden input
    MouseArea {
        anchors.fill: parent
        onClicked:    _input.forceActiveFocus()
        z:            -1
    }
}
