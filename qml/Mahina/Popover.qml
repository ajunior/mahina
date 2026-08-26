pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Anchored floating panel — like a Tooltip but with rich content and explicit open/close.
//
// Usage:
//   Button { id: btn; text: "Options"; onClicked: pop.open() }
//
//   Popover {
//       id:     pop
//       anchor: btn
//       title:  "Quick actions"
//
//       Button { text: "Rename";  variant: Button.Variant.Ghost }
//       Button { text: "Archive"; variant: Button.Variant.Ghost }
//   }
//
//   // Without a title:
//   Popover { anchor: avatarBtn; Text { text: "João Ribeiro" } }
//
//   // Different placement:
//   Popover { anchor: btn; position: Popover.Position.Top; ... }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    enum Position { Bottom, Top, Left, Right }

    property Item   anchor:         parent
    property string title:          ""
    property bool   closeable:      true
    property int    preferredWidth: 280
    property int    position:       Popover.Position.Bottom

    default property alias content: _body.data

    signal opened()
    signal closed()

    function open(): void { _popup.open()  }
    function close(): void { _popup.close() }

    // Zero-size — the popup itself positions via the overlay
    width:  0
    height: 0

    // ── Popup ─────────────────────────────────────────────────────────────────
    QQC.Popup {
        id:          _popup
        parent:      root.anchor !== null ? root.anchor : root
        closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside
        padding:     0

        width: Math.min(root.preferredWidth,
                        QQC.Overlay.overlay ? QQC.Overlay.overlay.width - Theme.sp8 * 2
                                            : root.preferredWidth)

        // Position relative to anchor
        x: {
            switch (root.position) {
                case Popover.Position.Left:  return -width - Theme.sp2
                case Popover.Position.Right: return (parent ? parent.width : 0) + Theme.sp2
                default:                     return parent ? Math.round((parent.width - width) / 2) : 0
            }
        }
        y: {
            switch (root.position) {
                case Popover.Position.Top: return -height - Theme.sp2
                case Popover.Position.Left:
                case Popover.Position.Right:
                    return parent ? Math.round((parent.height - height) / 2) : 0
                default:  // Bottom
                    return parent ? parent.height + Theme.sp2 : 0
            }
        }

        onOpened: root.opened()
        onClosed: root.closed()

        // ── Animations ────────────────────────────────────────────────────────
        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durationNormal; easing.type: Easing.OutCubic }
                NumberAnimation { property: "scale"; from: 0.96; to: 1.0; duration: Theme.durationNormal; easing.type: Easing.OutCubic }
            }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.durationFast; easing.type: Easing.InCubic }
        }

        // ── Background ────────────────────────────────────────────────────────
        background: Rectangle {
            color:        Theme.surface
            radius:       Theme.radiusMd
            border.color: Theme.border
            border.width: 1
        }

        // ── Content ───────────────────────────────────────────────────────────
        contentItem: ColumnLayout {
            spacing: 0

            // Header (shown when title is provided)
            RowLayout {
                visible:              root.title !== ""
                Layout.fillWidth:     true
                Layout.leftMargin:    Theme.sp4
                Layout.rightMargin:   Theme.sp3
                Layout.topMargin:     Theme.sp3
                Layout.bottomMargin:  Theme.sp3

                Text {
                    text:             root.title
                    color:            Theme.textPrimary
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.textSm
                    font.weight:      Theme.weightSemibold
                    Layout.fillWidth: true
                }

                // Close button
                Rectangle {
                    visible:       root.closeable
                    width:         24
                    height:        24
                    radius:        Theme.radiusSm
                    color:         _xHover.containsMouse ? Theme.border : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text:             "×"
                        color:            Theme.textSecondary
                        font.pixelSize:   16
                    }

                    HoverHandler  { id: _xHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    _popup.close()
                    }
                }
            }

            // Divider below header
            Rectangle {
                visible:          root.title !== ""
                Layout.fillWidth: true
                height:           1
                color:            Theme.border
            }

            // Body — user content
            Column {
                id:               _body
                Layout.fillWidth: true
                Layout.margins:   Theme.sp4
                spacing:          Theme.sp3
            }
        }
    }
}
