pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic
import Mahina

// Radio button — use inside RadioGroup for exclusive selection, or standalone
// with a ButtonGroup.
//
// Usage (standalone):
//   ButtonGroup { id: g }
//   Radio { text: "Option A"; ButtonGroup.group: g }
//   Radio { text: "Option B"; ButtonGroup.group: g; checked: true }
//
//   // With error state
//   Radio { text: "Required"; errorText: "Select one" }
RadioButton {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string errorText: ""
    readonly property bool hasError: errorText !== ""

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  contentItem.implicitWidth
    implicitHeight: contentItem.implicitHeight

    focusPolicy:   Qt.TabFocus
    spacing:       Theme.sp2
    topPadding:    0
    bottomPadding: 0
    leftPadding:   0
    rightPadding:  0

    // ── Indicator ─────────────────────────────────────────────────────────────
    indicator: Item {
        implicitWidth:  18
        implicitHeight: 18

        // Outer ring
        Rectangle {
            anchors.fill: parent
            radius:       width / 2
            color:        root.enabled ? Theme.surface : Theme.panel
            border.color: root.hasError  ? Theme.error
                        : !root.enabled  ? Theme.border
                        : root.checked   ? Theme.primary
                        : _hover.containsMouse ? Theme.borderStrong
                        : Theme.border
            border.width: root.activeFocus ? 2 : 1

            HoverHandler { id: _hover }

            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

            // Inner dot
            Rectangle {
                anchors.centerIn: parent
                width:   8
                height:  8
                radius:  width / 2
                color:   root.checked ? (root.enabled ? Theme.primary : Theme.textDisabled)
                                      : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            }
        }

        // Focus ring
        Rectangle {
            visible:         root.activeFocus
            anchors.fill:    parent
            anchors.margins: -3
            radius:          width / 2
            color:           "transparent"
            border.color:    Theme.primary
            border.width:    2
            opacity:         0.5
        }
    }

    // ── Content (label + error) ───────────────────────────────────────────────
    contentItem: Column {
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
}
