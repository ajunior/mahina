import QtQuick
import QtQuick.Layouts
import Mahina

// Chronological event list with icon dots and connector lines.
//
// Usage:
//   Timeline {
//       model: [
//           { title: "Account created",  description: "Welcome to Mahina",  time: "2 hours ago",  icon: Icons.userPlus, color: "success" },
//           { title: "Plan upgraded",    description: "Switched to Pro",   time: "1 day ago"                                           },
//           { title: "First login",      description: "From Paris, France",time: "3 days ago",  icon: Icons.signIn                     },
//       ]
//   }
//
// Item shape: { title, description?, time?, icon?, color? }
// color: "primary" | "success" | "warning" | "error" | "info" | hex string
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var    model:      []
    property real   dotSize:    32
    property real   lineWidth:  2

    // ── Layout ───────────────────────────────────────────────────────────────
    implicitWidth:  320
    implicitHeight: _col.implicitHeight

    Column {
        id:    _col
        width: parent.width

        Repeater {
            model: root.model

            delegate: RowLayout {
                id: _row
                required property var modelData
                required property int index

                width:   _col.width
                spacing: Theme.sp3

                // Computed on the delegate so children can reference _row._dotCol
                readonly property color _dotCol: {
                    switch (_row.modelData.color) {
                        case "primary": return Theme.primary
                        case "success": return Theme.success
                        case "warning": return Theme.warning
                        case "error":   return Theme.error
                        case "info":    return Theme.info
                        default:
                            // Treat unknown strings as hex colors; fall back to primary
                            return (_row.modelData.color && _row.modelData.color.startsWith("#"))
                                   ? _row.modelData.color : Theme.primary
                    }
                }

                // ── Left column: dot + connector ──────────────────────────────
                Item {
                    implicitWidth:  root.dotSize
                    implicitHeight: _rightCol.implicitHeight + (_row.index < root.model.length - 1 ? Theme.sp4 : 0)
                    Layout.alignment: Qt.AlignTop

                    // Connector line (below dot, except last item)
                    Rectangle {
                        visible:  _row.index < root.model.length - 1
                        x:        (root.dotSize - root.lineWidth) / 2
                        y:        root.dotSize
                        width:    root.lineWidth
                        height:   parent.height - root.dotSize
                        color:    Theme.border
                    }

                    // Dot background (faint fill)
                    Rectangle {
                        width:   root.dotSize
                        height:  root.dotSize
                        radius:  root.dotSize / 2
                        color:   _row._dotCol
                        opacity: 0.15
                    }

                    // Dot ring
                    Rectangle {
                        id:          _dotRing
                        width:       root.dotSize
                        height:      root.dotSize
                        radius:      root.dotSize / 2
                        color:       "transparent"
                        border.color: _row._dotCol
                        border.width: root.lineWidth
                    }

                    Icon {
                        anchors.centerIn: _dotRing
                        name:  _row.modelData.icon ?? Icons.clock
                        size:  root.dotSize * 0.5
                        color: _row._dotCol
                    }
                }

                // ── Right column: text ────────────────────────────────────────
                ColumnLayout {
                    id:               _rightCol
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: (root.dotSize - Theme.textBase * Theme.lineHeightNormal) / 2
                    spacing:          Theme.sp1

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.sp2

                        Text {
                            text:             _row.modelData.title ?? ""
                            color:            Theme.textPrimary
                            font.family:      Theme.fontFamily
                            font.pixelSize:   Theme.textSm
                            font.weight:      Theme.weightSemibold
                            Layout.fillWidth: true
                        }

                        Text {
                            visible:        _row.modelData.time !== undefined && _row.modelData.time !== ""
                            text:           _row.modelData.time ?? ""
                            color:          Theme.textDisabled
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textXs
                        }
                    }

                    Text {
                        visible:          _row.modelData.description !== undefined
                                          && _row.modelData.description !== ""
                        text:             _row.modelData.description ?? ""
                        color:            Theme.textSecondary
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.textSm
                        wrapMode:         Text.WordWrap
                        Layout.fillWidth: true
                    }

                    // Bottom spacing (gap between items)
                    Item {
                        visible: _row.index < root.model.length - 1
                        height:  Theme.sp4
                    }
                }
            }
        }
    }
}
