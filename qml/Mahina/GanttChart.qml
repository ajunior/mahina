pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as QQC
import Mahina

// Horizontal task timeline. Each task has a start and end (numeric or date string).
//
// Usage:
//   GanttChart {
//       tasks: [
//           { label: "Design",   start: 0, end: 3,  color: Theme.primary  },
//           { label: "Backend",  start: 2, end: 7,  color: Theme.success  },
//           { label: "Frontend", start: 4, end: 9,  color: Theme.warning  },
//           { label: "QA",       start: 8, end: 10, color: Theme.error    },
//       ]
//       xMin: 0; xMax: 10
//       xLabels: ["W1","W2","W3","W4","W5","W6","W7","W8","W9","W10","W11"]
//   }
Item {
    id: root

    property var    tasks:    []
    property real   xMin:     0
    property real   xMax:     10
    property var    xLabels:  []
    property real   rowHeight: 36
    property real   labelWidth: 90

    implicitWidth:  560
    implicitHeight: tasks.length * rowHeight + 32

    readonly property real _range: xMax - xMin || 1

    function _fx(v: var): var { return root.labelWidth + ((v - root.xMin) / root._range) * (root.width - root.labelWidth - 12) }

    // Header row
    Rectangle {
        width:  parent.width; height: 28
        color:  Theme.panel
        border.color: Theme.border; border.width: 1

        // Column labels
        Repeater {
            model: root.xLabels.length > 0 ? root.xLabels : []
            delegate: Text {
                required property string modelData
                required property int    index
                x: root._fx(root.xMin + index * (root._range / Math.max(1, root.xLabels.length - 1))) - implicitWidth / 2
                y: 6
                text:           modelData
                color:          Theme.textDisabled
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.textXs
            }
        }
    }

    // Task rows
    Column {
        anchors.top: parent.top; anchors.topMargin: 28
        width: parent.width
        spacing: 0

        Repeater {
            model: root.tasks
            delegate: Item {
                id: _rq1
                required property var  modelData
                required property int  index
                width:  parent.width
                height: root.rowHeight

                // Alternating row bg
                Rectangle {
                    anchors.fill: parent
                    color: _rq1.index % 2 === 0 ? "transparent" : Qt.rgba(Qt.color(Theme.panel).r, Qt.color(Theme.panel).g, Qt.color(Theme.panel).b, 0.5)
                }

                // Vertical grid lines
                Repeater {
                    model: root.xLabels.length
                    delegate: Rectangle {
                        required property int index
                        x: root._fx(root.xMin + index * (root._range / Math.max(1, root.xLabels.length - 1)))
                        width: 1; height: root.rowHeight
                        color: Theme.border
                    }
                }

                // Label
                Text {
                    anchors { left: parent.left; leftMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                    width:          root.labelWidth - Theme.sp2
                    text:           _rq1.modelData.label ?? ""
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    elide:          Text.ElideRight
                }

                // Bar
                Rectangle {
                    x:      root._fx(_rq1.modelData.start ?? 0)
                    y:      (root.rowHeight - 22) / 2
                    width:  root._fx(_rq1.modelData.end ?? 0) - root._fx(_rq1.modelData.start ?? 0)
                    height: 22
                    radius: Theme.radiusSm
                    color:  _rq1.modelData.color ?? Theme.primary

                    Text {
                        anchors { fill: parent; leftMargin: Theme.sp2; rightMargin: Theme.sp2 }
                        verticalAlignment: Text.AlignVCenter
                        text:           _rq1.modelData.label ?? ""
                        color:          "#ffffff"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.textXs
                        font.weight:    Theme.weightMedium
                        elide:          Text.ElideRight
                        visible:        parent.width > 30
                    }
                }
            }
        }
    }
}
