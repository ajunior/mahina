pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Mahina

// Numeric input field with increment / decrement stepper buttons.
//
// Usage:
//   NumberInput { label: "Quantity"; value: 1; min: 0; max: 99 }
//   NumberInput { value: 3.5; step: 0.5; decimals: 1; min: 0; max: 10 }
//   NumberInput { label: "Timeout (s)"; value: 30; step: 5; showValue: true }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property real   value:     0
    property real   min:      -Infinity
    property real   max:       Infinity
    property real   step:      1
    property int    decimals:  0
    property string label:     ""
    property string helper:    ""
    property string errorText: ""
    property bool   disabled:  false

    readonly property bool hasError: errorText !== ""
    readonly property real _fieldH: Theme.textBase + Theme.sp2 * 2 + 2

    // ── Stepper actions ───────────────────────────────────────────────────────
    function increment(): void {
        root.value = parseFloat(Math.min(root.max, root.value + root.step).toFixed(root.decimals))
        _field.text = root.value.toFixed(root.decimals)
    }
    function decrement(): void {
        root.value = parseFloat(Math.max(root.min, root.value - root.step).toFixed(root.decimals))
        _field.text = root.value.toFixed(root.decimals)
    }

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  160
    implicitHeight: _col.implicitHeight

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.sp1

        // Label
        Text {
            visible:        root.label !== ""
            text:           root.label
            color:          root.disabled ? Theme.textDisabled : Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textSm
            font.weight:    Theme.weightMedium
        }

        // ── Field group ───────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height:       root._fieldH
            radius:       Theme.radiusSm
            color:        Theme.surface
            border.width: _field.activeFocus ? 2 : 1
            border.color: root.hasError        ? Theme.error
                        : _field.activeFocus   ? Theme.primary
                        : _boxHover.hovered ? Theme.borderStrong
                        : Theme.border
            clip:         true

            HoverHandler { id: _boxHover }
            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
            Behavior on border.width { NumberAnimation { duration: Theme.durationFast } }

            RowLayout {
                anchors.fill: parent
                spacing:      0

                // ── Decrement ─────────────────────────────────────────────────
                Rectangle {
                    width:  root._fieldH
                    height: parent.height
                    color:  !root.disabled && _dHover.hovered ? Theme.panel : "transparent"
                    enabled: !root.disabled && root.value > root.min

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                    Text {
                        anchors.centerIn: parent
                        text:           "−"
                        color:          !root.disabled && root.value > root.min
                                        ? Theme.textPrimary : Theme.textDisabled
                        font.pixelSize: 16
                        font.weight:    Theme.weightRegular
                    }

                    HoverHandler { id: _dHover; enabled: !root.disabled && root.value > root.min }
                    MouseArea {
                        anchors.fill: parent
                        enabled:      !root.disabled && root.value > root.min
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.decrement()
                    }
                }

                // Divider
                Rectangle { width: 1; height: parent.height; color: Theme.border }

                // ── Value field ───────────────────────────────────────────────
                TextField {
                    id:               _field
                    Layout.fillWidth: true
                    text:             root.value.toFixed(root.decimals)
                    color:            root.disabled ? Theme.textDisabled : Theme.textPrimary
                    placeholderTextColor: Theme.textDisabled
                    enabled:          !root.disabled
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.textBase
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:   Text.AlignVCenter
                    background:       null
                    padding:          0
                    inputMethodHints: Qt.ImhFormattedNumbersOnly

                    Keys.onUpPressed:   root.increment()
                    Keys.onDownPressed: root.decrement()

                    onEditingFinished: {
                        var v = parseFloat(text)
                        if (!isNaN(v))
                            root.value = parseFloat(Math.max(root.min, Math.min(root.max, v)).toFixed(root.decimals))
                        text = root.value.toFixed(root.decimals)
                    }

                    // Sync display when value changes externally while not editing
                    Connections {
                        target: root
                        function onValueChanged(): void {
                            if (!_field.activeFocus)
                                _field.text = root.value.toFixed(root.decimals)
                        }
                    }
                }

                // Divider
                Rectangle { width: 1; height: parent.height; color: Theme.border }

                // ── Increment ─────────────────────────────────────────────────
                Rectangle {
                    width:  root._fieldH
                    height: parent.height
                    color:  !root.disabled && _iHover.hovered ? Theme.panel : "transparent"
                    enabled: !root.disabled && root.value < root.max

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                    Text {
                        anchors.centerIn: parent
                        text:           "+"
                        color:          !root.disabled && root.value < root.max
                                        ? Theme.textPrimary : Theme.textDisabled
                        font.pixelSize: 16
                        font.weight:    Theme.weightRegular
                    }

                    HoverHandler { id: _iHover; enabled: !root.disabled && root.value < root.max }
                    MouseArea {
                        anchors.fill: parent
                        enabled:      !root.disabled && root.value < root.max
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.increment()
                    }
                }
            }
        }

        // Helper / error
        Text {
            visible:        root.errorText !== "" || root.helper !== ""
            text:           root.errorText !== "" ? root.errorText : root.helper
            color:          root.errorText !== "" ? Theme.error : Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
        }
    }
}
