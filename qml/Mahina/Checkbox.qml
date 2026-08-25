import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Mahina

// Checkbox with optional label, error state, and indeterminate support.
//
// Usage:
//   Checkbox { text: "Accept terms" }
//   Checkbox { text: "Select all"; checkState: Qt.PartiallyChecked; tristate: true }
//   Checkbox { text: "Required"; errorText: "This field is required" }
CheckBox {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string errorText: ""
    readonly property bool hasError: errorText !== ""

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  _row.implicitWidth
    implicitHeight: _row.implicitHeight

    focusPolicy:   Qt.TabFocus
    spacing:       Theme.sp2
    topPadding:    0
    bottomPadding: 0
    leftPadding:   0
    rightPadding:  0

    // ── Indicator (the box) ───────────────────────────────────────────────────
    indicator: Rectangle {
        id:             _box
        implicitWidth:  18
        implicitHeight: 18
        radius:         Theme.radiusSm

        readonly property bool partiallyChecked: root.checkState === Qt.PartiallyChecked

        color: root.enabled
               ? (root.checked || partiallyChecked ? Theme.primary : Theme.surface)
               : Theme.panel

        border.color: root.hasError   ? Theme.error
                    : !root.enabled   ? Theme.border
                    : root.checked || partiallyChecked ? Theme.primary
                    : _hover.containsMouse ? Theme.borderStrong
                    : Theme.border
        border.width: root.activeFocus ? 2 : 1

        Behavior on color        { ColorAnimation { duration: Theme.durationFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

        HoverHandler { id: _hover }

        // Checkmark
        Text {
            anchors.centerIn: parent
            visible:          root.checked && !_box.partiallyChecked
            text:             "✓"
            color:            Theme.textOnPrimary
            font.pixelSize:   11
            font.weight:      Theme.weightBold
        }

        // Indeterminate dash
        Rectangle {
            anchors.centerIn: parent
            visible:          _box.partiallyChecked
            width:            10
            height:           2
            radius:           1
            color:            Theme.textOnPrimary
        }
    }

    // ── Content (label + error) ───────────────────────────────────────────────
    contentItem: Column {
        id:          _row
        spacing:     Theme.sp1
        leftPadding: root.indicator.width + root.spacing

        Text {
            id:                _label
            height:            root.indicator.implicitHeight
            verticalAlignment: Text.AlignVCenter
            text:              root.text
            visible:           root.text !== ""
            color:             root.enabled ? Theme.textPrimary : Theme.textDisabled
            font.family:       Theme.fontFamily
            font.pixelSize:    Theme.textSm
        }

        Text {
            text:           root.errorText
            visible:        root.hasError
            color:          Theme.error
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
        }
    }

    // ── Focus ring ────────────────────────────────────────────────────────────
    Rectangle {
        visible:      root.activeFocus
        anchors.fill: root.indicator
        anchors.margins: -3
        radius:       root.indicator.radius + 3
        color:        "transparent"
        border.color: Theme.primary
        border.width: 2
        opacity:      0.5
    }
}
