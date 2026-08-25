import QtQuick
import Mahina

// A section header that sticks to the top of a Flickable when the section
// scrolls past it. Wrap your Flickable content in StickySection items.
//
// Usage — inside a Flickable's contentItem Column:
//   Flickable {
//       id: _flick
//       Column {
//           StickySection { flickable: _flick; label: "January" }
//           // ... January items ...
//           StickySection { flickable: _flick; label: "February" }
//           // ... February items ...
//       }
//   }
Item {
    id: root

    property var    flickable: null
    property string label:     ""
    property real   headerHeight: 36
    property color  background: Theme.surface

    implicitWidth:  parent ? parent.width : 200
    implicitHeight: headerHeight

    // The sticky clone rendered at the top of the flickable
    Rectangle {
        parent:  root.flickable ?? root
        visible: root.flickable !== null && root.mapToItem(root.flickable, 0, 0).y < 0 &&
                 (root.y + root.height - root.flickable.contentY) > 0
        y:       Math.min(0, root.y - (root.flickable ? root.flickable.contentY : 0) + root.height) - root.headerHeight
        x:       0
        width:   root.flickable ? root.flickable.width : 0
        height:  root.headerHeight
        color:   root.background
        z:       10

        Text {
            anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
            text:           root.label
            color:          Theme.textPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            font.weight:    Theme.weightSemibold
        }
    }

    // Non-sticky header (always present in the layout flow)
    Rectangle {
        anchors.fill: parent
        color:        root.background
        border.color: Theme.border; border.width: 0
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border }

        Text {
            anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
            text:           root.label
            color:          Theme.textSecondary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.textXs
            font.weight:    Theme.weightSemibold
        }
    }
}
