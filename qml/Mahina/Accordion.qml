pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Collapsible disclosure panel with animated height transition.
//
// Usage:
//   Accordion {
//       title: "Advanced settings"
//       Text { Layout.fillWidth: true; text: "Some details here." }
//       Toggle { Layout.fillWidth: true; text: "Enable feature" }
//   }
//
//   // Section style — matches page section headings (uppercase, muted, with rule):
//   Accordion { style: Accordion.Style.Section; title: "Advanced"; ... }
//
//   // Start expanded:
//   Accordion { title: "Open by default"; expanded: true; ... }
//
//   // Compose multiple:
//   Column {
//       Accordion { title: "Section A"; Text { text: "…" } }
//       Accordion { title: "Section B"; Text { text: "…" } }
//   }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    enum Style { Default, Section }

    property string title:    ""
    property bool   expanded: false
    property bool   disabled: false
    property int    style:    Accordion.Style.Default

    default property alias content: _body.data

    signal toggled(bool expanded)

    readonly property bool _isSection: style === Accordion.Style.Section

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  300
    implicitHeight: _col.implicitHeight

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: 0

        // ── Header ────────────────────────────────────────────────────────────
        Rectangle {
            id:               _header
            Layout.fillWidth: true
            implicitHeight:   root._isSection ? 32 : 48
            color:            !root._isSection && _hHover.hovered && !root.disabled
                              ? Theme.panel : "transparent"
            radius:           (!root._isSection && root.expanded) ? 0 : Theme.radiusSm

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }

            HoverHandler { id: _hHover; enabled: !root.disabled }

            RowLayout {
                anchors {
                    fill:        parent
                    leftMargin:  root._isSection ? 0 : Theme.sp4
                    rightMargin: root._isSection ? 0 : Theme.sp4
                }
                spacing: root._isSection ? Theme.sp2 : Theme.sp3

                // Default title
                Text {
                    visible:          !root._isSection
                    text:             root.title
                    color:            root.disabled ? Theme.textDisabled : Theme.textPrimary
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.textBase
                    font.weight:      Theme.weightMedium
                    Layout.fillWidth: !root._isSection
                    elide:            Text.ElideRight
                }

                // Section title
                Text {
                    visible:            root._isSection
                    text:               root.title.toUpperCase()
                    color:              Theme.textDisabled
                    font.family:        Theme.fontFamily
                    font.pixelSize:     Theme.textXs
                    font.weight:        Theme.weightSemibold
                    font.letterSpacing: 1.5
                    elide:              Text.ElideRight
                }

                // Section horizontal rule
                Rectangle {
                    visible:          root._isSection
                    Layout.fillWidth: true
                    height:           1
                    color:            Theme.border
                }

                Icon {
                    name:  Icons.caretDown
                    size:  root._isSection ? 12 : 16
                    color: root._isSection ? Theme.textDisabled : Theme.textSecondary

                    rotation: root.expanded ? 180 : 0
                    Behavior on rotation {
                        NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled:      !root.disabled
                cursorShape:  Qt.PointingHandCursor
                onClicked: {
                    root.expanded = !root.expanded
                    root.toggled(root.expanded)
                }
            }
        }

        // Header bottom border — Default style only
        Rectangle {
            visible:          !root._isSection
            Layout.fillWidth: true
            height:           1
            color:            Theme.border
        }

        // ── Body (animated) ───────────────────────────────────────────────────
        Item {
            id:               _bodyWrap
            Layout.fillWidth: true
            implicitHeight:   root.expanded
                              ? _body.implicitHeight + Theme.sp4 + Theme.sp3
                              : 0
            clip:             true

            Behavior on implicitHeight {
                NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic }
            }

            ColumnLayout {
                id:           _body
                anchors.left:        parent.left
                anchors.right:       parent.right
                anchors.top:         parent.top
                anchors.topMargin:   Theme.sp3
                anchors.leftMargin:  root._isSection ? 0 : Theme.sp4
                anchors.rightMargin: root._isSection ? 0 : Theme.sp4
                spacing: Theme.sp3
            }
        }
    }
}
