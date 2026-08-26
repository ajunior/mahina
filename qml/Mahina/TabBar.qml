pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Mahina

// Horizontal tab bar with underline indicator.
//
// Usage:
//   TabBar {
//       model: ["Game", "Statistics", "Settings"]
//       currentIndex: 0
//       onCurrentIndexChanged: console.log(currentIndex)
//   }
Item {
    id: root

    // ── API ──────────────────────────────────────────────────────────────────
    property var   model:        []
    property int   currentIndex: 0
    property real  tabMinWidth:  80
    property real  tabHeight:    44
    property real  indicatorHeight: 2

    signal tabClicked(int index)

    // ── Sizing ───────────────────────────────────────────────────────────────
    implicitHeight: tabHeight
    implicitWidth:  _row.implicitWidth

    // ── Layout ────────────────────────────────────────────────────────────────
    Row {
        id:      _row
        height:  parent.height
        spacing: 0

        Repeater {
            model: root.model

            Item {
                id:     _tab
                required property string modelData
                required property int    index

                width:  Math.max(root.tabMinWidth, _label.implicitWidth + Theme.sp5 * 2)
                height: root.tabHeight

                readonly property bool selected: root.currentIndex === _tab.index

                Text {
                    id:                  _label
                    anchors.centerIn:    parent
                    text:                _tab.modelData
                    color:               _tab.selected ? Theme.primary : _tabMouse.containsMouse ? Theme.textPrimary : Theme.textSecondary
                    font.family:         Theme.fontFamily
                    font.pixelSize:      Theme.textSm
                    font.weight:         _tab.selected ? Theme.weightSemibold : Theme.weightRegular

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                }

                // Underline indicator
                Rectangle {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    anchors.bottom: parent.bottom
                    height:         root.indicatorHeight
                    color:          _tab.selected ? Theme.primary : "transparent"
                    radius:         1

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                }

                MouseArea {
                    id:            _tabMouse
                    anchors.fill:  parent
                    hoverEnabled:  true
                    cursorShape:   Qt.PointingHandCursor
                    onClicked: {
                        root.currentIndex = _tab.index
                        root.tabClicked(_tab.index)
                    }
                }
            }
        }
    }
}
