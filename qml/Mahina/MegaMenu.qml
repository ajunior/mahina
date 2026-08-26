pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Wide multi-column dropdown for top navigation.
//
// Usage:
//   MegaMenu {
//       sections: [
//           { heading: "Products",  items: [
//               { label: "Analytics",  icon: Icons.chartBar,  desc: "Dashboards & reports" },
//               { label: "Database",   icon: Icons.database,  desc: "Managed PostgreSQL"   },
//           ]},
//           { heading: "Resources", items: [
//               { label: "Docs",     icon: Icons.book,      desc: "API reference"  },
//               { label: "Blog",     icon: Icons.article,   desc: "News & updates" },
//           ]},
//       ]
//       open: _menuOpen
//       onItemSelected: (item) => navigate(item.label)
//   }
Item {
    id: root

    property var  sections:    []
    property bool open:        false
    property real columnWidth: 200
    property real itemHeight:  52

    signal itemSelected(var item)

    implicitWidth:  sections.length * columnWidth
    implicitHeight: open ? _panel.implicitHeight : 0

    Behavior on implicitHeight { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
    clip: true

    Rectangle {
        id:     _panel
        width:  parent.width
        implicitHeight: _row.implicitHeight + Theme.sp3 * 2
        color:  Theme.surface
        border.color: Theme.border; border.width: 1
        radius: Theme.radiusMd

        Row {
            id:     _row
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp3 }
            spacing: 0

            Repeater {
                model: root.sections
                delegate: Column {
                    id: _rq1
                    required property var  modelData
                    required property int  index
                    width:   root.columnWidth
                    spacing: 2
                    padding: Theme.sp2

                    // Section heading
                    Text {
                        text:           _rq1.modelData.heading ?? ""
                        color:          Theme.textDisabled
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        font.weight:    Theme.weightSemibold
                        leftPadding:    Theme.sp2
                        bottomPadding:  Theme.sp1
                    }

                    // Items
                    Repeater {
                        model: _rq1.modelData.items ?? []
                        delegate: Rectangle {
                            id: _rq2
                            required property var  modelData
                            width:   parent.width - Theme.sp2 * 2
                            height:  root.itemHeight
                            radius:  Theme.radiusMd
                            color:   _itemH.hovered ? Theme.hover : "transparent"
                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                            HoverHandler { id: _itemH }

                            Row {
                                anchors { fill: parent; margins: Theme.sp2 }
                                spacing: Theme.sp2

                                Text {
                                    visible: (_rq2.modelData.icon ?? "") !== ""
                                    text:    _rq2.modelData.icon ?? ""
                                    color:   Theme.primary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.textLg
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    Text {
                                        text:  _rq2.modelData.label ?? ""
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.textSm
                                        font.weight: Theme.weightMedium
                                    }
                                    Text {
                                        visible: (_rq2.modelData.desc ?? "") !== ""
                                        text:    _rq2.modelData.desc ?? ""
                                        color:   Theme.textSecondary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.textXs
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { root.itemSelected(_rq2.modelData); root.open = false }
                            }
                        }
                    }
                }
            }
        }
    }
}
