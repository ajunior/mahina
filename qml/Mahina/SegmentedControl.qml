import QtQuick
import QtQuick.Layouts
import Mahina

// Horizontal mutually-exclusive toggle group styled as a pill.
//
// Usage:
//   SegmentedControl {
//       model: ["Day", "Week", "Month"]
//       onSelectionChanged: (i) => changeView(i)
//   }
//
//   // With icons:
//   SegmentedControl {
//       model: [
//           { label: "Grid",  icon: Icons.squaresFour },
//           { label: "List",  icon: Icons.listBullets },
//           { label: "Table", icon: Icons.table        },
//       ]
//   }
//
// Item shape: string  OR  { label, icon? }
Item {
    id: root

    property var model:        []
    property int currentIndex: 0
    property bool disabled:    false

    signal selectionChanged(int index)

    implicitWidth:  _row.implicitWidth + Theme.sp1 * 2
    implicitHeight: 36

    Rectangle {
        anchors.fill: parent
        radius:       Theme.radiusMd
        color:        Theme.panel
        border.color: Theme.border
        border.width: 1

        // Sliding active pill
        Rectangle {
            id:     _pill
            x:      currentIndex < _row.children.length
                    ? _row.children[currentIndex].x + _row.x : Theme.sp1
            y:      Theme.sp1
            width:  currentIndex < _row.children.length
                    ? _row.children[currentIndex].width : 0
            height: parent.height - Theme.sp1 * 2
            radius: Theme.radiusSm
            color:  Theme.surface
            border.color: Theme.border
            border.width: 1

            Behavior on x { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic } }
        }

        Row {
            id:               _row
            anchors.fill:     parent
            anchors.margins:  Theme.sp1

            Repeater {
                model: root.model

                delegate: Item {
                    id: _rq1
                    required property var modelData
                    required property int index

                    readonly property string _label: typeof modelData === "string" ? modelData : (modelData.label ?? "")
                    readonly property string _icon:  typeof modelData === "string" ? "" : (modelData.icon ?? "")

                    width:  Math.max(64, _innerRow.implicitWidth + Theme.sp4 * 2)
                    height: _row.height

                    Row {
                        id:               _innerRow
                        anchors.centerIn: parent
                        spacing:          Theme.sp1

                        Icon {
                            visible: _icon !== ""
                            anchors.verticalCenter: parent.verticalCenter
                            name:  _icon
                            size:  14
                            color: _rq1.index === root.currentIndex ? Theme.textPrimary : Theme.textSecondary
                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        }

                        Text {
                            visible:        _label !== ""
                            anchors.verticalCenter: parent.verticalCenter
                            text:           _label
                            color:          _rq1.index === root.currentIndex ? Theme.textPrimary : Theme.textSecondary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            font.weight:    _rq1.index === root.currentIndex ? Theme.weightMedium : Theme.weightRegular
                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled:      !root.disabled
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    { root.currentIndex = _rq1.index; root.selectionChanged(_rq1.index) }
                    }
                }
            }
        }
    }
}
