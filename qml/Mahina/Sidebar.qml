import QtQuick
import QtQuick.Layouts
import Mahina

// Vertical navigation sidebar.
//
// Usage:
//   Sidebar {
//       title:    "MyApp"
//       subtitle: "v1.0.0"
//       currentIndex: 0
//       model: [
//           { icon: Icons.house,  label: "Dashboard" },
//           { icon: Icons.chart,  label: "Analytics" },
//           { icon: Icons.gear,   label: "Settings"  },
//       ]
//       onItemClicked: (i) => stack.currentIndex = i
//   }
Rectangle {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var    model:        []
    property int    currentIndex: 0
    property string title:        ""
    property string subtitle:     ""
    property string footerText:   ""

    signal itemClicked(int index)

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitWidth:  220
    implicitHeight: 480

    // ── Appearance ────────────────────────────────────────────────────────────
    color: Theme.surface

    // Right hairline border
    Rectangle {
        anchors.right:  parent.right
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: Theme.border
    }

    // ── Layout ────────────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Header ────────────────────────────────────────────────────────────
        ColumnLayout {
            visible:            root.title !== ""
            Layout.fillWidth:   true
            Layout.topMargin:   Theme.sp5
            Layout.bottomMargin: Theme.sp5
            Layout.leftMargin:  Theme.sp4
            Layout.rightMargin: Theme.sp4
            spacing:            Theme.sp1

            Text {
                text:           root.title
                visible:        root.title !== ""
                color:          Theme.textPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textBase
                font.weight:    Theme.weightSemibold
                Layout.fillWidth: true
            }

            Text {
                text:           root.subtitle
                visible:        root.subtitle !== ""
                color:          Theme.textSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
                Layout.fillWidth: true
            }
        }

        // Separator under header
        Rectangle {
            visible:          root.title !== ""
            Layout.fillWidth: true
            height:           1
            color:            Theme.border
        }

        // ── Nav items ─────────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth:   true
            Layout.fillHeight:  true
            Layout.topMargin:   Theme.sp3
            Layout.leftMargin:  Theme.sp3
            Layout.rightMargin: Theme.sp3
            spacing: 2

            Repeater {
                model: root.model

                Rectangle {
                    id:               _item
                    Layout.fillWidth: true
                    implicitHeight:   38
                    radius:           Theme.radiusSm

                    readonly property bool selected: root.currentIndex === index

                    color: selected              ? Theme.primarySubtle
                         : _mouse.containsMouse  ? Theme.panel
                         : "transparent"

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                    RowLayout {
                        anchors.fill:        parent
                        anchors.leftMargin:  Theme.sp3
                        anchors.rightMargin: Theme.sp3
                        spacing:             Theme.sp3

                        Icon {
                            name:  modelData.icon !== undefined ? modelData.icon : ""
                            size:  16
                            color: _item.selected ? Theme.primary : Theme.textSecondary
                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        }

                        Text {
                            text:           modelData.label !== undefined ? modelData.label : modelData
                            color:          _item.selected ? Theme.primary : Theme.textSecondary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    _item.selected ? Theme.weightSemibold : Theme.weightRegular
                            Layout.fillWidth: true
                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        }
                    }

                    MouseArea {
                        id:           _mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            root.currentIndex = index
                            root.itemClicked(index)
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }

        // Separator above footer
        Rectangle {
            visible:          root.footerText !== ""
            Layout.fillWidth: true
            height:           1
            color:            Theme.border
        }

        // ── Footer ────────────────────────────────────────────────────────────
        Text {
            visible:              root.footerText !== ""
            text:                 root.footerText
            color:                Theme.textDisabled
            font.family:          Theme.fontFamily
            font.pixelSize:       Theme.textXs
            horizontalAlignment:  Text.AlignHCenter
            Layout.fillWidth:     true
            Layout.topMargin:     Theme.sp3
            Layout.bottomMargin:  Theme.sp3
        }
    }
}
