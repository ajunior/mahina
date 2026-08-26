pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Grid layout manager where each child specifies its position in grid units.
// Assign gsX, gsY, gsW, gsH to children via the items model.
//
// Usage:
//   GridStack {
//       columns: 4; rowHeight: 100; gap: 8
//       items: [
//           { x:0, y:0, w:2, h:1, label:"Widget A", color:Theme.primary   },
//           { x:2, y:0, w:2, h:1, label:"Widget B", color:Theme.success   },
//           { x:0, y:1, w:4, h:2, label:"Big Panel", color:Theme.warning  },
//       ]
//   }
Item {
    id: root

    property int columns:    4
    property int rowHeight:  100
    property int gap:        8
    property var gridItems:  []

    // Compute total height from items
    readonly property int rows: {
        var maxRow = 0
        for (var i = 0; i < root.gridItems.length; i++) {
            var it = root.gridItems[i]
            var bottom = (it.y || 0) + (it.h || 1)
            if (bottom > maxRow) maxRow = bottom
        }
        return Math.max(maxRow, 1)
    }

    implicitWidth:  400
    implicitHeight: root.rows * (root.rowHeight + root.gap) - root.gap

    Repeater {
        model: root.gridItems
        delegate: Rectangle {
            id: _rq1
            required property var  modelData
            required property int  index

            readonly property real cellW: (root.width + root.gap) / root.columns - root.gap
            readonly property real gx:   (modelData.x || 0)
            readonly property real gy:   (modelData.y || 0)
            readonly property real gw:   (modelData.w || 1)
            readonly property real gh:   (modelData.h || 1)

            x:      gx * (cellW + root.gap)
            y:      gy * (root.rowHeight + root.gap)
            width:  gw * (cellW + root.gap) - root.gap
            height: gh * (root.rowHeight + root.gap) - root.gap

            radius: Theme.radiusMd
            color: modelData.color
                ? Qt.rgba(Qt.color(modelData.color).r, Qt.color(modelData.color).g,
                          Qt.color(modelData.color).b, 0.1)
                : Theme.surfaceVariant
            border.color: modelData.color
                ? Qt.rgba(Qt.color(modelData.color).r, Qt.color(modelData.color).g,
                          Qt.color(modelData.color).b, 0.3)
                : Theme.border
            border.width: 1

            // Header bar
            Rectangle {
                width:  parent.width; height: 3
                radius: parent.radius
                color:  _rq1.modelData.color || Theme.primary
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width; height: parent.radius
                    color: parent.color
                }
            }

            Column {
                anchors { fill: parent; margins: 10 }
                spacing: 4

                Text {
                    text:           _rq1.modelData.label || ""
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    font.weight:    Font.Medium
                    elide:          Text.ElideRight
                    width:          parent.width
                }

                Text {
                    visible:        (_rq1.modelData.value || "") !== ""
                    text:           _rq1.modelData.value || ""
                    color:          Theme.textSecondary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textXs
                    width:          parent.width
                    wrapMode:       Text.Wrap
                }
            }
        }
    }
}
