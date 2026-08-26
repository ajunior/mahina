pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Header that compresses when its linked Flickable is scrolled.
//
// Usage:
//   StickyHeader {
//       scrollTarget:    _myFlickable
//       expandedHeight:  80
//       compressedHeight: 44
//       Text { text: "Page Title"; font.pixelSize: root.height > 60 ? 28 : 16 }
//   }
Item {
    id: root

    property Item   scrollTarget:     null
    property real   expandedHeight:   80
    property real   compressedHeight: 44
    property real   scrollThreshold:  60
    property color  bgColor:          Theme.surface

    default property alias content: _headerContent.data

    implicitWidth:  parent ? parent.width : 400
    implicitHeight: _currentH

    readonly property real _scrollY: scrollTarget ? scrollTarget.contentY : 0
    readonly property real _progress: scrollTarget
                                      ? Math.max(0, Math.min(1, _scrollY / root.scrollThreshold))
                                      : 0

    property real _currentH: root.expandedHeight +
                              (_progress) * (root.compressedHeight - root.expandedHeight)

    Behavior on _currentH { NumberAnimation { duration: 80 } }

    Rectangle {
        anchors.fill: parent
        color: root.bgColor
        opacity: 0.95

        // Bottom shadow line
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1
            color: Qt.rgba(Qt.color(Theme.border).r, Qt.color(Theme.border).g,
                           Qt.color(Theme.border).b, root._progress)
        }
    }

    Item {
        id:    _headerContent
        anchors.fill: parent
        clip:  true
    }
}
