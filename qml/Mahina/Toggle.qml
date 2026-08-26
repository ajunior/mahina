pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Mahina

// Toggle / switch component.
//
// Usage:
//   Toggle { text: "Dark mode" }
//   Toggle { text: "Notifications"; checked: true }
//   Toggle { text: "Disabled option"; enabled: false }
Switch {
    id: root

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  contentItem.implicitWidth + indicator.implicitWidth + spacing
    implicitHeight: Math.max(indicator.implicitHeight, contentItem.implicitHeight)

    focusPolicy: Qt.TabFocus
    spacing:     Theme.sp2

    // ── Track dimensions ──────────────────────────────────────────────────────
    readonly property real _trackW:  40
    readonly property real _trackH:  22
    readonly property real _thumbSz: 16
    readonly property real _pad:     (_trackH - _thumbSz) / 2

    // ── Indicator (track + thumb) ─────────────────────────────────────────────
    indicator: Rectangle {
        implicitWidth:  root._trackW
        implicitHeight: root._trackH
        radius:         root._trackH / 2

        color: root.enabled
               ? (root.checked ? Theme.primary : (_hover.hovered ? Theme.borderStrong : Theme.border))
               : Theme.panel

        Behavior on color { ColorAnimation { duration: Theme.durationNormal } }

        HoverHandler { id: _hover; enabled: root.enabled }

        // Thumb
        Rectangle {
            width:  root._thumbSz
            height: root._thumbSz
            radius: root._thumbSz / 2
            color:  root.enabled ? "#FFFFFF" : Theme.textDisabled

            // `position` goes 0.0 → 1.0 as Switch animates, giving smooth motion
            x: root._pad + root.position * (parent.width - width - root._pad * 2)
            y: root._pad

            // Inner shadow hint to make thumb read as raised
            Rectangle {
                anchors.fill:   parent
                radius:         parent.radius
                color:          "transparent"
                border.color:   "#00000018"
                border.width:   1
            }
        }
    }

    // ── Content (label) ───────────────────────────────────────────────────────
    contentItem: Text {
        text:             root.text
        visible:          root.text !== ""
        color:            root.enabled ? Theme.textPrimary : Theme.textDisabled
        font.family:      Theme.fontFamily
        font.pixelSize:   Theme.textSm
        verticalAlignment: Text.AlignVCenter
        leftPadding:      root.indicator.implicitWidth + root.spacing
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
