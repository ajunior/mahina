import QtQuick
import QtQuick.Layouts
import Mahina

// Horizontal progress bar — determinate and indeterminate modes.
//
// Usage:
//   ProgressBar { value: 0.6 }
//   ProgressBar { label: "Uploading"; showValue: true; value: 0.42 }
//   ProgressBar { indeterminate: true }
//   ProgressBar { value: 1.0; colorScheme: ProgressBar.Color.Success; size: ProgressBar.Size.Sm }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    enum Color { Primary, Success, Warning, Error, Info }
    enum Size  { Sm, Md }

    property real   value:         0.0     // 0.0 – 1.0
    property bool   indeterminate: false
    property string label:         ""
    property bool   showValue:     false
    property int    colorScheme:   ProgressBar.Color.Primary
    property int    size:          ProgressBar.Size.Md

    // ── Resolved values ───────────────────────────────────────────────────────
    readonly property real _h: root.size === ProgressBar.Size.Sm ? 4 : 8

    readonly property color _color: {
        switch (root.colorScheme) {
            case ProgressBar.Color.Success: return Theme.success
            case ProgressBar.Color.Warning: return Theme.warning
            case ProgressBar.Color.Error:   return Theme.error
            case ProgressBar.Color.Info:    return Theme.info
            default:                        return Theme.primary
        }
    }

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  200
    implicitHeight: _col.implicitHeight

    // ── Layout ────────────────────────────────────────────────────────────────
    Column {
        id:      _col
        width:   parent.width
        spacing: Theme.sp2

        // Label + percentage
        RowLayout {
            visible: root.label !== "" || (root.showValue && !root.indeterminate)
            width:   parent.width

            Text {
                text:           root.label
                visible:        root.label !== ""
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                Layout.fillWidth: true
            }

            Text {
                text:                Math.round(root.value * 100) + "%"
                visible:             root.showValue && !root.indeterminate
                color:               Theme.textSecondary
                font.family:         Theme.fontFamily
                font.pixelSize:      Theme.textSm
                font.weight:         Theme.weightMedium
                horizontalAlignment: Text.AlignRight
            }
        }

        // Track
        Rectangle {
            width:  parent.width
            height: root._h
            radius: root._h / 2
            color:  Theme.panel
            clip:   true

            // Determinate fill
            Rectangle {
                visible: !root.indeterminate
                height:  parent.height
                radius:  parent.radius
                color:   root._color
                width:   parent.width * Math.max(0.0, Math.min(1.0, root.value))

                Behavior on width {
                    NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic }
                }
            }

            // Indeterminate sweeping bar
            Rectangle {
                id:      _bar
                visible: root.indeterminate
                height:  parent.height
                radius:  parent.radius
                width:   parent.width * 0.38
                color:   root._color

                SequentialAnimation on x {
                    loops:   Animation.Infinite
                    running: root.indeterminate

                    NumberAnimation {
                        from:     -_bar.width
                        to:       _bar.parent.width
                        duration: 1100
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }
    }
}
