pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Horizontal range input with label, value display, helper, and error states.
//
// Usage:
//   Slider { label: "Volume"; from: 0; to: 100; value: 50; showValue: true }
//   Slider { label: "Price"; from: 0; to: 1000; stepSize: 10; decimals: 0 }
//   Slider { errorText: "Value out of range" }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property alias value:    _slider.value
    property alias from:     _slider.from
    property alias to:       _slider.to
    property alias stepSize: _slider.stepSize
    property alias live:     _slider.live

    property string label:     ""
    property bool   showValue: false
    property int    decimals:  0
    property string helper:    ""
    property string errorText: ""
    property bool   disabled:  false

    readonly property bool hasError: errorText !== ""

    signal moved()

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  200
    implicitHeight: _col.implicitHeight

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.sp2

        // Label + live value
        RowLayout {
            visible:          root.label !== "" || root.showValue
            Layout.fillWidth: true

            Text {
                text:             root.label
                visible:          root.label !== ""
                color:            root.disabled ? Theme.textDisabled : Theme.textPrimary
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.textSm
                font.weight:      Theme.weightMedium
                Layout.fillWidth: true
            }

            Text {
                text:           root.value.toFixed(root.decimals)
                visible:        root.showValue
                color:          root.disabled ? Theme.textDisabled : Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                font.weight:    Theme.weightMedium
            }
        }

        // ── Slider control ────────────────────────────────────────────────────
        QQC.Slider {
            id:               _slider
            Layout.fillWidth: true
            from:             0
            to:               1
            value:            0.5
            enabled:          !root.disabled
            focusPolicy:      Qt.TabFocus
            onMoved:          root.moved()

            background: Rectangle {
                x:      _slider.leftPadding
                y:      _slider.topPadding + (_slider.availableHeight - height) / 2
                width:  _slider.availableWidth
                height: 4
                radius: 2
                color:  _slider.enabled ? Theme.border : Theme.panel

                // Filled portion
                Rectangle {
                    width:  _slider.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color:  _slider.enabled
                            ? (root.hasError ? Theme.error : Theme.primary)
                            : Theme.borderStrong

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                }
            }

            handle: Item {
                x: _slider.leftPadding + _slider.visualPosition * (_slider.availableWidth - width)
                y: _slider.topPadding  + (_slider.availableHeight - height) / 2
                implicitWidth:  18
                implicitHeight: 18

                Rectangle {
                    anchors.fill: parent
                    radius:       width / 2
                    color:        _slider.enabled ? Theme.surface : Theme.panel
                    border.color: root.hasError      ? Theme.error
                                : _slider.pressed    ? Theme.primaryActive
                                : _hHover.containsMouse ? Theme.primaryHover
                                : Theme.primary
                    border.width: _slider.pressed ? 3 : 2

                    HoverHandler { id: _hHover }

                    Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
                    Behavior on border.width { NumberAnimation { duration: Theme.durationFast } }
                }

                // Focus ring
                Rectangle {
                    visible:         _slider.activeFocus
                    anchors.fill:    parent
                    anchors.margins: -3
                    radius:          width / 2
                    color:           "transparent"
                    border.color:    Theme.primary
                    border.width:    2
                    opacity:         0.5
                }
            }
        }

        // Helper / error text
        Text {
            visible:        root.errorText !== "" || root.helper !== ""
            text:           root.errorText !== "" ? root.errorText : root.helper
            color:          root.errorText !== "" ? Theme.error : Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
        }
    }
}
