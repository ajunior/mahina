pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as QQC
import Mahina

// Right-click context menu. Attach to any Item via the anchor property.
//
// Usage:
//   Item {
//       id: myCard
//       ContextMenu {
//           anchor: myCard
//           model: [
//               { label: "Copy",   icon: Icons.copy   },
//               { label: "Paste",  icon: Icons.clipboard },
//               null,
//               { label: "Delete", icon: Icons.trash, danger: true },
//           ]
//           onTriggered: (index, item) => handleAction(item)
//       }
//   }
//
// Null entries in model render as horizontal dividers.
// Item shape: { label, icon?, shortcut?, danger?, disabled? }
Item {
    id: root

    property Item   anchor:  parent
    property var    model:   []
    property real   menuWidth: 220

    signal triggered(int index, var item)

    // Zero-size host — doesn't participate in layout
    width: 0; height: 0; visible: false

    // ── Right-click capture ───────────────────────────────────────────────────
    Loader {
        id: _maLoader
        sourceComponent: Component {
            MouseArea {
                parent:          root.anchor
                anchors.fill:    parent
                acceptedButtons: Qt.RightButton
                propagateComposedEvents: true
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        _popup.x = mouse.x
                        _popup.y = mouse.y
                        _popup.open()
                        mouse.accepted = true
                    }
                }
            }
        }
        active: root.anchor !== null
    }

    // ── Popup ─────────────────────────────────────────────────────────────────
    QQC.Popup {
        id:          _popup
        parent:      root.anchor ?? root
        padding:     Theme.sp1
        width:       root.menuWidth
        closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside

        enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.durationFast } }
        exit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.durationFast } }

        background: Rectangle {
            color:        Theme.surface
            radius:       Theme.radiusMd
            border.color: Theme.border
            border.width: 1
        }

        contentItem: Column {
            Repeater {
                model: root.model

                delegate: Item {
                    id: _rq1
                    required property var modelData
                    required property int index

                    readonly property bool isDivider: modelData === null
                    readonly property bool isDanger:  !isDivider && (modelData.danger   ?? false)
                    readonly property bool isDisabled:!isDivider && (modelData.disabled ?? false)

                    width:  _popup.width - Theme.sp1 * 2
                    height: isDivider ? Theme.sp1 * 2 + 1 : 36

                    // ── Divider variant ──────────────────────────────────────
                    Rectangle {
                        visible: isDivider
                        anchors.centerIn: parent
                        width:  parent.width; height: 1; color: Theme.border
                    }

                    // ── Row variant ───────────────────────────────────────────
                    Rectangle {
                        visible: !isDivider
                        anchors.fill: parent
                        radius: Theme.radiusSm
                        color: isDisabled ? "transparent"
                             : _h.containsMouse ? (isDanger ? Theme.errorSubtle : Theme.panel)
                             : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        HoverHandler { id: _h; enabled: !isDisabled && !isDivider }

                        RowLayout {
                            anchors { fill: parent; leftMargin: Theme.sp3; rightMargin: Theme.sp3 }
                            spacing: Theme.sp2

                            Icon {
                                visible:  !isDivider && _rq1.modelData.icon !== undefined && _rq1.modelData.icon !== ""
                                name:  !isDivider && _rq1.modelData.icon ? _rq1.modelData.icon : ""
                                size:  15
                                color: isDisabled ? Theme.textDisabled : isDanger ? Theme.error : Theme.textSecondary
                            }

                            Text {
                                text:             !isDivider ? (_rq1.modelData.label ?? "") : ""
                                color:            isDisabled ? Theme.textDisabled : isDanger ? Theme.error : Theme.textPrimary
                                font.family:      Theme.fontFamily
                                font.pixelSize:   Theme.textSm
                                Layout.fillWidth: true
                            }

                            Text {
                                visible:        !isDivider && _rq1.modelData.shortcut !== undefined
                                text:           !isDivider && _rq1.modelData.shortcut ? _rq1.modelData.shortcut : ""
                                color:          Theme.textDisabled
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.textXs
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            enabled:      !isDisabled && !isDivider
                            onClicked:    { _popup.close(); root.triggered(_rq1.index, _rq1.modelData) }
                        }
                    }
                }
            }
        }
    }
}
