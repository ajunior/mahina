import QtQuick
import Mahina

// Numeric input with increment / decrement buttons.
//
// Usage:
//   NumberStepper {
//       stepperValue: 10; from: 0; to: 100; stepSize: 5; suffix: "%"
//       onValueModified: (v) => applyOpacity(v / 100)
//   }
Item {
    id: root

    property real   stepperValue: 0
    property real   from:         0
    property real   to:           100
    property real   stepSize:     1
    property int    decimals:     0
    property string suffix:       ""

    signal valueModified(real val)

    implicitWidth:  130
    implicitHeight: 36

    function _clamp(v) { return Math.max(root.from, Math.min(root.to, v)) }
    function _fmt(v)   { return v.toFixed(root.decimals) + root.suffix }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSm
        color:  Theme.surface
        border.color: _numInput.activeFocus ? Theme.primary : Theme.border
        border.width: 1
        clip: true

        // Decrease button
        Rectangle {
            id:     _decBtn
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width:  32
            color:  _decH.hovered ? Theme.panel : "transparent"
            Behavior on color { ColorAnimation { duration: 80 } }
            HoverHandler { id: _decH }

            Text { anchors.centerIn: parent; text: "−"; color: Theme.textPrimary; font.pixelSize: 16 }
            Rectangle { anchors { right: parent.right; top: parent.top; bottom: parent.bottom } width: 1; color: Theme.border }

            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.stepperValue = _clamp(Math.round((root.stepperValue - root.stepSize) * 1e9) / 1e9)
                    root.valueModified(root.stepperValue)
                    _numInput.text = _fmt(root.stepperValue)
                }
            }
        }

        // Text input
        Item {
            anchors { left: _decBtn.right; right: _incBtn.left; top: parent.top; bottom: parent.bottom }

            TextInput {
                id:    _numInput
                anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
                text:               _fmt(root.stepperValue)
                horizontalAlignment: TextInput.AlignHCenter
                color:              Theme.textPrimary
                font.family:        Theme.fontFamily
                font.pixelSize:     Theme.textSm
                selectByMouse:      true
                inputMethodHints:   Qt.ImhFormattedNumbersOnly

                onEditingFinished: {
                    var raw = text.replace(root.suffix, "")
                    var v   = parseFloat(raw)
                    if (!isNaN(v)) {
                        root.stepperValue = _clamp(v)
                        root.valueModified(root.stepperValue)
                    }
                    text = _fmt(root.stepperValue)
                }
            }
        }

        // Increase button
        Rectangle {
            id:    _incBtn
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
            width: 32
            color: _incH.hovered ? Theme.panel : "transparent"
            Behavior on color { ColorAnimation { duration: 80 } }
            HoverHandler { id: _incH }

            Text { anchors.centerIn: parent; text: "+"; color: Theme.textPrimary; font.pixelSize: 16 }
            Rectangle { anchors { left: parent.left; top: parent.top; bottom: parent.bottom } width: 1; color: Theme.border }

            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.stepperValue = _clamp(Math.round((root.stepperValue + root.stepSize) * 1e9) / 1e9)
                    root.valueModified(root.stepperValue)
                    _numInput.text = _fmt(root.stepperValue)
                }
            }
        }
    }
}
