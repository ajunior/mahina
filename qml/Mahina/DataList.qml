import QtQuick
import QtQuick.Layouts
import Mahina

// Key-value description list.
//
// Usage:
//   DataList {
//       model: [
//           { label: "Name",   value: "Alice Chen"        },
//           { label: "Role",   value: "Administrator"     },
//           { label: "Email",  value: "alice@example.com" },
//           { label: "Plan",   value: "Pro",  badge: true },
//       ]
//   }
//
//   // Striped:
//   DataList { model: [...]; striped: true }
//
//   // Compact (no dividers):
//   DataList { model: [...]; divided: false }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var    model:          []
    property bool   striped:        false
    property bool   divided:        true
    property real   labelMinWidth:  100
    property real   rowHeight:      40

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  300
    implicitHeight: root.model.length * root.rowHeight

    Column {
        width: parent.width

        Repeater {
            model: root.model

            delegate: Item {
                id: _rq1
                required property var modelData
                required property int index

                width:  parent.width
                height: root.rowHeight

                // Striped background
                Rectangle {
                    anchors.fill: parent
                    color: root.striped && _rq1.index % 2 === 1
                           ? Theme.panel : "transparent"
                }

                // Bottom divider
                Rectangle {
                    visible: root.divided && _rq1.index < root.model.length - 1
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: 1
                    color:  Theme.border
                }

                RowLayout {
                    anchors {
                        fill:        parent
                        leftMargin:  Theme.sp4
                        rightMargin: Theme.sp4
                    }
                    spacing: Theme.sp4

                    // Label
                    Text {
                        text:             _rq1.modelData.label ?? ""
                        color:            Theme.textSecondary
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.textSm
                        font.weight:      Theme.weightMedium
                        Layout.minimumWidth:   root.labelMinWidth
                        Layout.preferredWidth: root.labelMinWidth
                    }

                    // Value
                    Text {
                        text:             _rq1.modelData.value ?? ""
                        color:            Theme.textPrimary
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.textSm
                        elide:            Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // Optional badge
                    Rectangle {
                        visible:       _rq1.modelData.badge === true
                        implicitWidth: _badgeText.implicitWidth + Theme.sp2 * 2
                        height:        20
                        radius:        Theme.radiusSm
                        color:         Theme.primarySubtle

                        Text {
                            id:               _badgeText
                            anchors.centerIn: parent
                            text:             _rq1.modelData.value ?? ""
                            color:            Theme.primary
                            font.family:      Theme.fontFamily
                            font.pixelSize:   Theme.textXs
                            font.weight:      Theme.weightSemibold
                        }
                    }
                }
            }
        }
    }
}
