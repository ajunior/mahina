pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Slider with a linked number input showing and editing the exact value.
//
// Usage:
//   SliderWithInput { min: 0; max: 100; value: 42 }
//   SliderWithInput { min: 0.0; max: 1.0; step: 0.01; decimals: 2; value: 0.5 }
Item {
    id: root

    property real   value:    0
    property real   min:      0
    property real   max:      100
    property real   step:     1
    property int    decimals: 0
    property string unit:     ""

    signal valueEdited(real v)

    implicitWidth:  280
    implicitHeight: 40

    Row {
        anchors.fill: parent
        spacing: Theme.sp3

        // Slider track
        Item {
            width:  parent.width - _numBox.width - Theme.sp3
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id:     _track
                anchors.verticalCenter: parent.verticalCenter
                width:  parent.width; height: 4; radius: 2
                color:  Theme.border

                Rectangle {
                    width:  _thumb.x + _thumb.width / 2
                    height: parent.height; radius: 2
                    color:  Theme.primary
                }
            }

            Rectangle {
                id:      _thumb
                width:   18; height: 18; radius: 9
                color:   Theme.surface
                border.color: Theme.primary; border.width: 2
                anchors.verticalCenter: _track.verticalCenter
                x: ((root.value - root.min) / (root.max - root.min)) * (_track.width - width)

                Behavior on x { NumberAnimation { duration: Theme.durationFast } }

                MouseArea {
                    anchors.fill: parent
                    drag.target: parent
                    drag.axis:   Drag.XAxis
                    drag.minimumX: 0
                    drag.maximumX: _track.width - parent.width

                    onPositionChanged: {
                        if (drag.active) {
                            var frac  = _thumb.x / (_track.width - _thumb.width)
                            var raw   = root.min + frac * (root.max - root.min)
                            var snapped = root.step > 0 ? Math.round(raw / root.step) * root.step : raw
                            root.value = Math.max(root.min, Math.min(root.max, snapped))
                            root.valueEdited(root.value)
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: _track
                onClicked: (m) => {
                    var frac = m.x / _track.width
                    var raw  = root.min + frac * (root.max - root.min)
                    var snapped = root.step > 0 ? Math.round(raw / root.step) * root.step : raw
                    root.value = Math.max(root.min, Math.min(root.max, snapped))
                    root.valueEdited(root.value)
                }
            }
        }

        // Number input
        Rectangle {
            id:     _numBox
            width:  60 + (root.unit !== "" ? 14 : 0); height: 32
            color:  Theme.surface
            radius: Theme.radiusMd
            border.color: _ni.activeFocus ? Theme.primary : Theme.border
            border.width: _ni.activeFocus ? 2 : 1
            anchors.verticalCenter: parent.verticalCenter
            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

            Row {
                anchors.centerIn: parent
                spacing: 2

                TextInput {
                    id:             _ni
                    width:          42
                    horizontalAlignment: Text.AlignRight
                    text:           root.value.toFixed(root.decimals)
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamilyMono
                    font.pixelSize: Theme.textSm
                    selectByMouse:  true

                    onEditingFinished: {
                        var v = parseFloat(text)
                        if (!isNaN(v)) {
                            root.value = Math.max(root.min, Math.min(root.max, v))
                            root.valueEdited(root.value)
                        }
                        text = root.value.toFixed(root.decimals)
                    }
                }

                Text {
                    visible:        root.unit !== ""
                    text:           root.unit
                    color:          Theme.textDisabled
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
