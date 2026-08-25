import QtQuick
import Mahina

// Compact color dot + hex text input. Lighter alternative to ColorPicker.
//
// Usage:
//   ColorSwatch { color: "#5B8DF6" }
//   ColorSwatch { color: Theme.success; showHex: true }
Item {
    id: root

    property color  color:   "#5B8DF6"
    property bool   showHex: true
    property bool   editable: true

    signal colorPicked(color c)
    signal clicked()

    implicitWidth:  showHex ? 110 : 28
    implicitHeight: 28

    Row {
        anchors.fill: parent
        spacing: Theme.sp2

        // Color dot
        Rectangle {
            width:  28; height: 28; radius: Theme.radiusSm
            color:  root.color
            border.color: Theme.border; border.width: 1

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked:    root.clicked()
            }
        }

        // Hex input
        Rectangle {
            visible: root.showHex
            width:  78; height: 28
            color:  Theme.surface
            radius: Theme.radiusMd
            border.color: _hexInput.activeFocus ? Theme.primary : Theme.border
            border.width: _hexInput.activeFocus ? 2 : 1
            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

            TextInput {
                id:             _hexInput
                anchors { fill: parent; leftMargin: Theme.sp2; rightMargin: Theme.sp2 }
                verticalAlignment: TextInput.AlignVCenter
                text:           root.color.toString().toUpperCase().substring(0, 7)
                color:          Theme.textPrimary
                font.family:    Theme.fontFamilyMono
                font.pixelSize: Theme.textXs
                readOnly:       !root.editable
                maximumLength:  7
                selectByMouse:  true

                onEditingFinished: {
                    var t = text.trim()
                    if (!/^#[0-9A-Fa-f]{6}$/.test(t)) { text = root.color.toString().toUpperCase().substring(0, 7); return }
                    root.color = t
                    root.colorPicked(root.color)
                }
            }
        }
    }
}
