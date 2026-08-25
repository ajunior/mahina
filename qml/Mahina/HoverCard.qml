import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Rich popup that appears on hover over an anchor item.
//
// Usage:
//   Button {
//       id: _btn
//       text: "Hover me"
//       HoverCard {
//           anchor: _btn
//           Text { text: "Opens the settings panel" }
//       }
//   }
//
//   // With title:
//   HoverCard { anchor: _avatar; title: "Alice Chen"
//       ColumnLayout {
//           Text { text: "Administrator"; color: Theme.textSecondary }
//           Text { text: "alice@example.com"; color: Theme.textSecondary }
//       }
//   }
//
// Place HoverCard as a sibling or child of its anchor; it uses QQC.Popup for correct layering.
Item {
    id: root

    default property alias content: _body.data
    property Item   anchor:         parent
    property string title:          ""
    property real   preferredWidth: 220
    property int    delay:          400    // ms before showing (avoids flicker)

    width: 0; height: 0; visible: false

    // ── Hover detection on anchor ─────────────────────────────────────────────
    Loader {
        id: _hoverLoader
        sourceComponent: Component {
            HoverHandler {
                parent:   root.anchor
                onHoveredChanged: {
                    if (hovered) _delayTimer.start()
                    else { _delayTimer.stop(); _popup.close() }
                }
            }
        }
        active: root.anchor !== null
    }

    Timer {
        id:       _delayTimer
        interval: root.delay
        onTriggered: _popup.open()
    }

    // ── Popup ─────────────────────────────────────────────────────────────────
    QQC.Popup {
        id:      _popup
        parent:  root.anchor ?? root
        // Position above or below based on available space
        y:       (root.anchor && root.anchor.y + root.anchor.height + height + Theme.sp2 < (root.anchor.Window.height ?? 800))
                 ? root.anchor.height + Theme.sp2
                 : -(height + Theme.sp2)
        x:       0
        width:   Math.min(root.preferredWidth,
                          (root.anchor ? root.anchor.Window.width - Theme.sp8 : 300))
        padding: Theme.sp4
        closePolicy: QQC.Popup.NoAutoClose

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durationNormal; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.durationFast }
        }

        background: Rectangle {
            color:        Theme.surface
            radius:       Theme.radiusMd
            border.color: Theme.border
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: Theme.sp2

            Text {
                visible:          root.title !== ""
                text:             root.title
                color:            Theme.textPrimary
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.textSm
                font.weight:      Theme.weightSemibold
                Layout.fillWidth: true
            }

            Item {
                id:               _body
                visible:          children.length > 0
                implicitHeight:   childrenRect.height
                Layout.fillWidth: true
            }
        }
    }
}
