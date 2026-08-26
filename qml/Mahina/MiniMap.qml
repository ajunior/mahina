pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Scrollable content overview thumbnail — links to a Flickable.
//
// Usage:
//   MiniMap {
//       scrollTarget: _myFlickable
//       width: 100; height: 140
//   }
Item {
    id: root

    property Item  scrollTarget: null
    property color thumbColor:   Theme.primary
    property color bgColor:      Theme.surfaceVariant

    implicitWidth:  100
    implicitHeight: 120

    readonly property real _vRatio: scrollTarget && scrollTarget.contentHeight > 0
                                    ? root.height / scrollTarget.contentHeight : 1
    readonly property real _hRatio: scrollTarget && scrollTarget.contentWidth > 0
                                    ? root.width  / scrollTarget.contentWidth  : 1
    readonly property real _vPos:   scrollTarget
                                    ? scrollTarget.contentY / Math.max(1, scrollTarget.contentHeight) * root.height : 0
    readonly property real _hPos:   scrollTarget
                                    ? scrollTarget.contentX / Math.max(1, scrollTarget.contentWidth) * root.width  : 0

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSm
        color:  root.bgColor
        border.color: Theme.border; border.width: 1
        clip: true

        // Viewport thumb
        Rectangle {
            x:      root._hPos
            y:      root._vPos
            width:  Math.max(12, root.width  * root._hRatio)
            height: Math.max(8,  root.height * root._vRatio)
            radius: 3
            color:  Qt.rgba(Qt.color(root.thumbColor).r, Qt.color(root.thumbColor).g,
                            Qt.color(root.thumbColor).b, 0.25)
            border.color: root.thumbColor; border.width: 1

            Behavior on x { NumberAnimation { duration: 60 } }
            Behavior on y { NumberAnimation { duration: 60 } }
        }

        // Click to jump
        MouseArea {
            anchors.fill: parent
            onClicked: (m) => {
                if (!root.scrollTarget) return
                var nx = (m.x / root.width)  * root.scrollTarget.contentWidth
                var ny = (m.y / root.height) * root.scrollTarget.contentHeight
                root.scrollTarget.contentX = Math.max(0, Math.min(
                    root.scrollTarget.contentWidth  - root.scrollTarget.width, nx))
                root.scrollTarget.contentY = Math.max(0, Math.min(
                    root.scrollTarget.contentHeight - root.scrollTarget.height, ny))
            }
        }
    }
}
