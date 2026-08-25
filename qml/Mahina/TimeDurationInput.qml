import QtQuick
import Mahina

// HH:MM:SS duration input with increment/decrement buttons.
//
// Usage:
//   TimeDurationInput {
//       totalSeconds: 3665    // 1:01:05
//       onDurationEdited: (secs) => timer.setDuration(secs)
//   }
Item {
    id: root

    property int totalSeconds: 0
    property int maxHours:     99

    signal durationEdited(int seconds)

    implicitWidth:  220
    implicitHeight: 48

    // Break into parts
    property int hours:   Math.min(maxHours, Math.floor(totalSeconds / 3600))
    property int minutes: Math.floor((totalSeconds % 3600) / 60)
    property int seconds: totalSeconds % 60

    function _rebuild() {
        var h = Math.min(root.maxHours, Math.max(0, root.hours))
        var m = Math.max(0, Math.min(59, root.minutes))
        var s = Math.max(0, Math.min(59, root.seconds))
        root.totalSeconds = h * 3600 + m * 60 + s
        root.durationEdited(root.totalSeconds)
    }

    Row {
        anchors.fill: parent
        spacing: 4

        // Hours
        DurationField {
            value:    root.hours
            maxValue: root.maxHours
            label:    "h"
            onIncremented: { root.hours = Math.min(root.maxHours, root.hours + 1); root._rebuild() }
            onDecremented: { root.hours = Math.max(0, root.hours - 1); root._rebuild() }
            onEdited: (v) => { root.hours = v; root._rebuild() }
        }

        Text {
            text:  ":"
            color: Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textBase
            anchors.verticalCenter: parent.verticalCenter
        }

        // Minutes
        DurationField {
            value:    root.minutes
            maxValue: 59
            label:    "m"
            onIncremented: {
                root.minutes++
                if (root.minutes >= 60) { root.minutes = 0; root.hours = Math.min(root.maxHours, root.hours + 1) }
                root._rebuild()
            }
            onDecremented: {
                root.minutes--
                if (root.minutes < 0) { root.minutes = 59; root.hours = Math.max(0, root.hours - 1) }
                root._rebuild()
            }
            onEdited: (v) => { root.minutes = Math.min(59, v); root._rebuild() }
        }

        Text {
            text:  ":"
            color: Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textBase
            anchors.verticalCenter: parent.verticalCenter
        }

        // Seconds
        DurationField {
            value:    root.seconds
            maxValue: 59
            label:    "s"
            onIncremented: {
                root.seconds++
                if (root.seconds >= 60) { root.seconds = 0; root.minutes++
                    if (root.minutes >= 60) { root.minutes = 0; root.hours = Math.min(root.maxHours, root.hours+1) }
                }
                root._rebuild()
            }
            onDecremented: {
                root.seconds--
                if (root.seconds < 0) { root.seconds = 59; root.minutes--
                    if (root.minutes < 0) { root.minutes = 59; root.hours = Math.max(0, root.hours-1) }
                }
                root._rebuild()
            }
            onEdited: (v) => { root.seconds = Math.min(59, v); root._rebuild() }
        }
    }

    component DurationField: Item {
        id:    _field
        width: 60; height: 48

        property int    value:    0
        property int    maxValue: 99
        property string label:    ""

        signal incremented()
        signal decremented()
        signal edited(int value)

        Column {
            anchors.fill: parent
            spacing: 0

            // Up button
            Rectangle {
                width:  parent.width; height: 14
                color:  _upH.containsMouse ? Theme.panel : "transparent"
                radius: Theme.radiusSm
                HoverHandler { id: _upH }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: _field.incremented() }
                Text {
                    anchors.centerIn: parent
                    text:  "▲"
                    color: _upH.containsMouse ? Theme.textPrimary : Theme.textDisabled
                    font.pixelSize: 7
                }
            }

            // Value field
            Rectangle {
                width:  parent.width; height: parent.height - 28
                color:  _ti.activeFocus ? Theme.surface : Theme.panel
                border.color: _ti.activeFocus ? Theme.primary : Theme.border
                border.width: 1; radius: Theme.radiusSm

                Row {
                    anchors.centerIn: parent
                    spacing: 2
                    TextInput {
                        id:    _ti
                        width: 26
                        text:  String(_field.value).padStart(2, "0")
                        color: Theme.textPrimary
                        font.family:    Theme.fontFamilyMono
                        font.pixelSize: Theme.textBase
                        font.weight:    Theme.weightMedium
                        horizontalAlignment: TextInput.AlignRight
                        inputMethodHints: Qt.ImhDigitsOnly
                        selectByMouse: true
                        onEditingFinished: {
                            var v = parseInt(text) || 0
                            _field.edited(Math.min(_field.maxValue, Math.max(0, v)))
                        }
                        onActiveFocusChanged: if (activeFocus) selectAll()
                    }
                    Text {
                        text:  _field.label
                        color: Theme.textDisabled
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Down button
            Rectangle {
                width:  parent.width; height: 14
                color:  _downH.containsMouse ? Theme.panel : "transparent"
                radius: Theme.radiusSm
                HoverHandler { id: _downH }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: _field.decremented() }
                Text {
                    anchors.centerIn: parent
                    text:  "▼"
                    color: _downH.containsMouse ? Theme.textPrimary : Theme.textDisabled
                    font.pixelSize: 7
                }
            }
        }
    }
}
