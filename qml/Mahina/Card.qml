pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

Rectangle {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property string title:    ""
    property string subtitle: ""
    property bool   outlined: true
    property bool   hoverable: false
    default property alias content: _body.data

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  300
    implicitHeight: _layout.implicitHeight + Theme.sp6 * 2

    // ── Appearance ────────────────────────────────────────────────────────────
    color:        Theme.surface
    radius:       Theme.radiusLg
    border.color: outlined ? Theme.border : "transparent"
    border.width: outlined ? 1 : 0

    layer.enabled: !outlined
    layer.effect: null  // attach DropShadow externally if desired

    // Hover lift
    scale: hoverable && _hover.hovered ? 1.015 : 1.0
    Behavior on scale { NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easing } }

    HoverHandler { id: _hover; enabled: root.hoverable }

    // ── Layout ────────────────────────────────────────────────────────────────
    ColumnLayout {
        id: _layout
        anchors {
            left:   parent.left
            right:  parent.right
            top:    parent.top
            margins: Theme.sp6
        }
        spacing: Theme.sp4

        // Header
        ColumnLayout {
            visible: root.title !== "" || root.subtitle !== ""
            spacing: Theme.sp1

            Text {
                text:           root.title
                visible:        root.title !== ""
                color:          Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textLg
                font.weight:    Theme.weightSemibold
                wrapMode:       Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                text:           root.subtitle
                visible:        root.subtitle !== ""
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textSm
                wrapMode:       Text.WordWrap
                Layout.fillWidth: true
            }
        }

        // Content slot
        Item {
            id:               _body
            implicitHeight:   childrenRect.height
            Layout.fillWidth: true
        }
    }
}
